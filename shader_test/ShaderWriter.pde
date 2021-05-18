import java.io.FileWriter;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
static class ShaderWriter {
  public void setVariable(int lineNumber, String data) throws IOException {
    Path path = Paths.get("data/main.glsl");
    List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
    lines.set(lineNumber - 1, data);
    Files.write(path, lines, StandardCharsets.UTF_8);
  }
  public static void testPath(){
       Path path = Paths.get("data/main.glsl");
       print(path);
  }
}
