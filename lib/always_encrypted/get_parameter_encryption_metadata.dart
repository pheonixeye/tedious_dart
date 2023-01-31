import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/always_encrypted/cek_entry.dart';
import 'package:tedious_dart/always_encrypted/key_crypto.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

void getParameterEncryptionMetadata(
  Connection connection,
  Request request,
  Function({Error? error}) callback,
) {
  if (request.cryptoMetadataLoaded == true) {
    callback();
  }

  final metadataRequest = Request('sp_describe_parameter_encryption', (error) {
    if (error != null) {
      return callback(error: error);
    }

    List<Future<void>> decryptSymmetricKeyPromises = [];
    List<CEKEntry?> cekList = [];
    var paramCount = 0;
    var resultRows = [];

    for (var columns in resultRows) {
      try {
        var isFirstRecordSet = columns.some((col) =>
            (col && col.metadata && col.metadata.colName) == 'database_id');
        if (isFirstRecordSet == true) {
          var currentOrdinal =
              columns[DescribeParameterEncryptionResultSet1.KeyOrdinal].value;
          CEKEntry cekEntry;
          if (cekList[currentOrdinal] != null) {
            cekEntry = CEKEntry(currentOrdinal);
            cekList[cekEntry.ordinal as int] = cekEntry;
          } else {
            cekEntry = cekList[currentOrdinal]!;
          }
          cekEntry.add(
              columns[DescribeParameterEncryptionResultSet1.EncryptedKey].value,
              columns[DescribeParameterEncryptionResultSet1.DbId].value,
              columns[DescribeParameterEncryptionResultSet1.KeyId].value,
              columns[DescribeParameterEncryptionResultSet1.KeyVersion].value,
              columns[DescribeParameterEncryptionResultSet1.KeyMdVersion].value,
              columns[DescribeParameterEncryptionResultSet1.KeyPath].value,
              columns[DescribeParameterEncryptionResultSet1.ProviderName].value,
              columns[DescribeParameterEncryptionResultSet1
                      .KeyEncryptionAlgorithm]
                  .value);
        } else {
          paramCount++;
          String paramName =
              columns[DescribeParameterEncryptionResultSet2.ParameterName]
                  .value;
          num paramIndex = request.parameters
              .findIndex((Parameter param) => paramName == "@${param.name}");
          num cekOrdinal = columns[DescribeParameterEncryptionResultSet2
                  .ColumnEncryptionKeyOrdinal]
              .value;
          CEKEntry? cekEntry = cekList[cekOrdinal as int];

          if (cekEntry != null && cekList.length < cekOrdinal) {
            return callback(
                error: MTypeError(
                    "Internal error. The referenced column encryption key ordinal $cekOrdinal is missing in the encryption metadata returned by sp_describe_parameter_encryption. Max ordinal is ${cekList.length}."));
          }

          var encType =
              columns[DescribeParameterEncryptionResultSet2.ColumnEncrytionType]
                  .value;
          if (SQLServerEncryptionType.PlainText != encType) {
            request.parameters[paramIndex].cryptoMetadata = CryptoMetadata(
              cekEntry: cekEntry,
              ordinal: cekOrdinal,
              cipherAlgorithmId: columns[DescribeParameterEncryptionResultSet2
                      .ColumnEncryptionAlgorithm]
                  .value,
              encryptionType: encType,
              normalizationRuleVersion: Buffer.from([
                columns[DescribeParameterEncryptionResultSet2
                        .NormalizationRuleVersion]
                    .value
              ]),
            );
            decryptSymmetricKeyPromises.add(decryptSymmetricKey(
                request.parameters[paramIndex].cryptoMetadata as CryptoMetadata,
                connection.config.options));
          } else if (request.parameters[paramIndex].forceEncrypt == true) {
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
    return Future.forEach(decryptSymmetricKeyPromises, (element) {
      request.cryptoMetadataLoaded = true;
      process.nextTick(callback);
    }).onError((error, stackTrace) {
      process.nextTick(callback, error);
    });
    // return Promise.all(decryptSymmetricKeyPromises).then(() {}, (error) {});
  });

  metadataRequest.addParameter(
      'tsql', TYPES.NVarChar, request.sqlTextOrProcedure);
  if (request.parameters.length) {
    metadataRequest.addParameter('params', TYPES.NVarChar,
        metadataRequest.makeParamsParameter(request.parameters));
  }

  metadataRequest.on('row', (columns) => {resultRows.add(columns)});

  connection.makeRequest(
      metadataRequest,
      TYPE.RPC_REQUEST,
      new RpcRequestPayload(
          metadataRequest.sqlTextOrProcedure!,
          metadataRequest.parameters,
          connection.currentTransactionDescriptor(),
          connection.config.options,
          connection.databaseCollation));
}
