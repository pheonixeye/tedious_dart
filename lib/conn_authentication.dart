abstract class Authentication {
  String get type;
  AuthOptions? get options;
}

class AuthOptions {
  String? clientId;
  String? token;
  String? userName;
  String? password;
  String? tenantId;
  String? clientSecret;
  String? domain;
  AuthOptions({
    this.clientId,
    this.clientSecret,
    this.domain,
    this.password,
    this.tenantId,
    this.token,
    this.userName,
  });
}

class AzureActiveDirectoryMsiAppServiceAuthentication extends Authentication {
  AzureActiveDirectoryMsiAppServiceAuthentication({
    required this.clientId,
  });
  final String? clientId;
  @override
  AuthOptions get options => AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-msi-app-service';
}

class AzureActiveDirectoryMsiVmAuthentication extends Authentication {
  AzureActiveDirectoryMsiVmAuthentication({
    required this.clientId,
  });
  final String? clientId;
  @override
  AuthOptions get options => AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-msi-vm';
}

class AzureActiveDirectoryDefaultAuthentication extends Authentication {
  AzureActiveDirectoryDefaultAuthentication({
    required this.clientId,
  });
  final String? clientId;
  @override
  AuthOptions get options => AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-default';
}

class AzureActiveDirectoryAccessTokenAuthentication extends Authentication {
  AzureActiveDirectoryAccessTokenAuthentication({
    required this.token,
  });
  final String? token;
  @override
  AuthOptions get options => AuthOptions(
        token: token,
      );

  @override
  String get type => 'azure-active-directory-access-token';
}

class AzureActiveDirectoryPasswordAuthentication extends Authentication {
  AzureActiveDirectoryPasswordAuthentication({
    required this.userName,
    required this.password,
    required this.clientId,
    required this.tenantId,
  });
  final String? userName;
  final String? password;
  final String? clientId;
  final String? tenantId;
  @override
  AuthOptions get options => AuthOptions(
        userName: userName,
        password: password,
        clientId: clientId,
        tenantId: tenantId,
      );

  @override
  String get type => 'azure-active-directory-password';
}

class AzureActiveDirectoryServicePrincipalSecret extends Authentication {
  AzureActiveDirectoryServicePrincipalSecret({
    required this.clientId,
    required this.tenantId,
    required this.clientSecret,
  });
  final String? clientId;
  final String? tenantId;
  final String? clientSecret;
  @override
  AuthOptions get options => AuthOptions(
        clientId: clientId,
        tenantId: tenantId,
        clientSecret: clientSecret,
      );

  @override
  String get type => 'azure-active-directory-service-principal-secret';
}

class NtlmAuthentication extends Authentication {
  NtlmAuthentication({
    required this.userName,
    required this.password,
    required this.domain,
  });
  final String? userName;
  final String? password;
  final String? domain;
  @override
  AuthOptions get options => AuthOptions(
        userName: userName,
        password: password,
        domain: domain,
      );

  @override
  String get type => 'ntlm';
}

class DefaultAuthentication extends Authentication {
  DefaultAuthentication({
    required this.userName,
    required this.password,
  });
  final String? userName;
  final String? password;
  @override
  AuthOptions get options => AuthOptions(
        userName: userName,
        password: password,
      );

  @override
  String get type => 'default';
}

class AuthenticationType {
  late Authentication _auth;
  final String type;
  final AuthOptions options;

  Authentication get auth => _auth;
  AuthenticationType({
    required this.type,
    required this.options,
  }) {
    switch (type) {
      case 'ntlm':
        _auth = NtlmAuthentication(
          userName: options.userName,
          password: options.password,
          domain: options.domain,
        );
        break;
      case 'azure-active-directory-password':
        _auth = AzureActiveDirectoryPasswordAuthentication(
          userName: options.userName,
          password: options.password,
          clientId: options.clientId,
          tenantId: options.tenantId,
        );
        break;
      case 'azure-active-directory-msi-app-service':
        _auth = AzureActiveDirectoryMsiAppServiceAuthentication(
          clientId: options.clientId,
        );
        break;
      case 'azure-active-directory-msi-vm':
        _auth = AzureActiveDirectoryMsiVmAuthentication(
          clientId: options.clientId,
        );
        break;
      case 'azure-active-directory-access-token':
        _auth = AzureActiveDirectoryAccessTokenAuthentication(
          token: options.token,
        );
        break;
      case 'azure-active-directory-service-principal-secret':
        _auth = AzureActiveDirectoryServicePrincipalSecret(
          clientId: options.clientId,
          clientSecret: options.clientSecret,
          tenantId: options.tenantId,
        );
        break;
      case 'azure-active-directory-default':
        _auth = AzureActiveDirectoryDefaultAuthentication(
          clientId: options.clientId,
        );
        break;
      case 'default':
        _auth = DefaultAuthentication(
          userName: options.userName,
          password: options.password,
        );
        break;
      default:
        _auth = DefaultAuthentication(
          userName: null,
          password: null,
        );
    }
  }
}
