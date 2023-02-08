import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/always_encrypted/cek_entry.dart';
import 'package:tedious_dart/always_encrypted/key_crypto.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/request.dart';
import 'package:tedious_dart/rpcrequest_payload.dart';

void getParameterEncryptionMetadata(
  Connection connection,
  Request request,
  Function({Error? error}) callback,
) {
  if (request.cryptoMetadataLoaded == true) {
    callback();
  }

  final metadataRequest = Request(
      sqlTextOrProcedure: 'sp_describe_parameter_encryption',
      callback: ({error, rowCount, rows}) async {
        if (error != null) {
          return callback(error: error);
        }

        List<Future<void>> decryptSymmetricKeyPromises = [];
        List<CEKEntry?> cekList = [];
        var paramCount = 0;
        var resultRows = [];

        for (List columns in resultRows) {
          try {
            var isFirstRecordSet = columns.any((col) {
              if (col != null &&
                  col.metadata != null &&
                  col.metadata.colName != null) {
                return col.metadata.colName == 'database_id';
              }
              return false;
            });
            if (isFirstRecordSet == true) {
              var currentOrdinal = columns[
                      DescribeParameterEncryptionResultSet1.KeyOrdinal.index]
                  .value;
              CEKEntry cekEntry;
              if (cekList[currentOrdinal] != null) {
                cekEntry = CEKEntry(currentOrdinal);
                cekList[cekEntry.ordinal as int] = cekEntry;
              } else {
                cekEntry = cekList[currentOrdinal]!;
              }
              cekEntry.add(
                  columns[DescribeParameterEncryptionResultSet1
                          .EncryptedKey.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1.DbId.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1.KeyId.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1
                          .KeyVersion.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1
                          .KeyMdVersion.index]
                      .value,
                  columns[
                          DescribeParameterEncryptionResultSet1.KeyPath.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1
                          .ProviderName.index]
                      .value,
                  columns[DescribeParameterEncryptionResultSet1
                          .KeyEncryptionAlgorithm.index]
                      .value);
            } else {
              paramCount++;
              String paramName = columns[
                      DescribeParameterEncryptionResultSet2.ParameterName.index]
                  .value;
              num paramIndex = request.parameters.indexWhere(
                  (Parameter param) => paramName == "@${param.name}");
              num cekOrdinal = columns[DescribeParameterEncryptionResultSet2
                      .ColumnEncryptionKeyOrdinal.index]
                  .value;
              CEKEntry? cekEntry = cekList[cekOrdinal as int];

              if (cekEntry != null && cekList.length < cekOrdinal) {
                return callback(
                    error: MTypeError(
                        "Internal error. The referenced column encryption key ordinal $cekOrdinal is missing in the encryption metadata returned by sp_describe_parameter_encryption. Max ordinal is ${cekList.length}."));
              }

              var encType = columns[DescribeParameterEncryptionResultSet2
                      .ColumnEncrytionType.index]
                  .value;
              if (SQLServerEncryptionType.PlainText != encType) {
                request.parameters[paramIndex as int].cryptoMetadata =
                    CryptoMetadata(
                  cekEntry: cekEntry,
                  ordinal: cekOrdinal,
                  cipherAlgorithmId: columns[
                          DescribeParameterEncryptionResultSet2
                              .ColumnEncryptionAlgorithm.index]
                      .value,
                  encryptionType: encType,
                  normalizationRuleVersion: Buffer.from([
                    columns[DescribeParameterEncryptionResultSet2
                            .NormalizationRuleVersion.index]
                        .value
                  ]),
                );
                decryptSymmetricKeyPromises.add(decryptSymmetricKey(
                    request.parameters[paramIndex].cryptoMetadata
                        as CryptoMetadata,
                    connection.config!.options! as ConnectionOptions));
              } else if (request.parameters[paramIndex as int].forceEncrypt ==
                  true) {
                return callback(
                    error: MTypeError(
                        "Cannot execute statement or procedure ${request.sqlTextOrProcedure} because Force Encryption was set as true for parameter ${paramIndex + 1} and the database expects this parameter to be sent as plaintext. This may be due to a configuration error."));
              }
            }
          } catch (e) {
            return callback(
                error: MTypeError(
                    "Internal error. Unable to parse parameter encryption metadata in statement or procedure ${request.sqlTextOrProcedure}"));
          }
        }

        if (paramCount != request.parameters.length) {
          return callback(
              error: MTypeError(
                  "Internal error. Metadata for some parameters in statement or procedure ${request.sqlTextOrProcedure} is missing in the resultset returned by sp_describe_parameter_encryption."));
        }
        return await Future.forEach(decryptSymmetricKeyPromises, (element) {
          request.cryptoMetadataLoaded = true;
          process.nextTick(callback);
        }).onError((error, stackTrace) {
          process.nextTick(callback, error);
        });
        // return Promise.all(decryptSymmetricKeyPromises).then(() {}, (error) {});
      });

  metadataRequest.addParameter('tsql', DATATYPES.NVarChar,
      request.sqlTextOrProcedure, ParameterOptions());
  if (request.parameters.isEmpty) {
    metadataRequest.addParameter('params', DATATYPES.NVarChar,
        metadataRequest.makeParamsParameter(request.parameters));
  }

  metadataRequest.on('row', (columns) => {resultRows.add(columns)});

  connection.makeRequest(
      metadataRequest,
      PACKETTYPE['RPC_REQUEST']!,
      RpcRequestPayload(
          procedure: metadataRequest.sqlTextOrProcedure!,
          parameters: metadataRequest.parameters,
          txnDescriptor: connection.currentTransactionDescriptor(),
          options: connection.config!.options!,
          collation: connection.databaseCollation));
}

void todo() {
//TODO!: needs serious revision
}
