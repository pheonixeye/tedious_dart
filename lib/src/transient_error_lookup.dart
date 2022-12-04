// This simple piece of code is factored out into a separate class to make it

// easy to stub it out in tests. It's hard, if not impossible, to cause a

// transient error on demand in tests.
class TransientErrorLookup {
  isTransientError(num error) {
    // This list of transient errors comes from Microsoft implementation of SqlClient:

    //  - https://github.com/dotnet/corefx/blob/master/src/System.Data.SqlClient/src/System/Data/SqlClient/SqlInternalConnectionTds.cs#L115
    final List<num> transientErrors = [4060, 10928, 10929, 40197, 40501, 40613];
    return !identical(transientErrors.indexOf(error), -1);
  }
}
