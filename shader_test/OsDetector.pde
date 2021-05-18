static class OsDetector {
  public static String GetOS () {
    if (System.getProperty("os.name").contains("Windows")) {
      return "Windows";
    } else if (System.getProperty("os.name").contains("Mac")) {
      return "MacOS";
    } else if (System.getProperty("os.name").contains("Linux")) {
      return "Linux";
    } else {
      return "other";
    }
  }
}
