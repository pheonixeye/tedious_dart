// ignore_for_file: constant_identifier_names

enum AuthType {
  default_('default'),
  azure_active_directory_msi_app_service_(
      "azure-active-directory-msi-app-service"),
  azure_active_directory_msi_vm_("azure-active-directory-msi-vm"),
  azure_active_directory_default_("azure-active-directory-default"),
  azure_active_directory_access_token_("azure-active-directory-access-token"),
  azure_active_directory_password_("azure-active-directory-password"),
  azure_active_directory_service_principal_secret_(
      "azure-active-directory-service-principal-secret"),
  ntlm_("ntlm");

  final String value;

  const AuthType(this.value);
}

abstract class Authentication {
  String get type;
  AuthOptions? get options;
}

class AuthOptions {
  final String? clientId;
  final String? token;
  final String? userName;
  final String? password;
  final String? tenantId;
  final String? clientSecret;
  final String? domain;
  const AuthOptions({
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
  final Authentication _auth;
  final AuthType type;
  final AuthOptions options;

  Authentication get auth => _auth;

  factory AuthenticationType.empty() {
    return AuthenticationType(
        type: AuthType.default_,
        options: AuthOptions(
          userName: 'admin',
          password: 'password',
        ));
  }

  AuthenticationType({
    required this.type,
    required this.options,
  }) : _auth = switch (type) {
          AuthType.ntlm_ => NtlmAuthentication(
              userName: options.userName,
              password: options.password,
              domain: options.domain,
            ),
          AuthType.azure_active_directory_password_ =>
            AzureActiveDirectoryPasswordAuthentication(
              userName: options.userName,
              password: options.password,
              clientId: options.clientId,
              tenantId: options.tenantId,
            ),
          AuthType.azure_active_directory_msi_app_service_ =>
            AzureActiveDirectoryMsiAppServiceAuthentication(
              clientId: options.clientId,
            ),
          AuthType.azure_active_directory_msi_vm_ =>
            AzureActiveDirectoryMsiVmAuthentication(
              clientId: options.clientId,
            ),
          AuthType.azure_active_directory_access_token_ =>
            AzureActiveDirectoryAccessTokenAuthentication(
              token: options.token,
            ),
          AuthType.azure_active_directory_service_principal_secret_ =>
            AzureActiveDirectoryServicePrincipalSecret(
              clientId: options.clientId,
              clientSecret: options.clientSecret,
              tenantId: options.tenantId,
            ),
          AuthType.azure_active_directory_default_ =>
            AzureActiveDirectoryDefaultAuthentication(
              clientId: options.clientId,
            ),
          AuthType.default_ => DefaultAuthentication(
              userName: options.userName,
              password: options.password,
            ),
        };
}
