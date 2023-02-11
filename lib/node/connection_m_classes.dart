class UsernamePasswordCredential {
  final String? tenantId;
  final String? clientId;
  final String? userName;
  final String? password;
  UsernamePasswordCredential(
    this.tenantId,
    this.clientId,
    this.userName,
    this.password,
  );
}

class ManagedIdentityCredential {
  final List<dynamic> args;
  ManagedIdentityCredential(this.args);
}

class DefaultAzureCredential {
  final Map<dynamic, dynamic> args;
  DefaultAzureCredential(this.args);
}
