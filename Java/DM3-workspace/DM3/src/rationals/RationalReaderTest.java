package rationals;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.Test;

public class RationalReaderTest implements WithAssertions {

   @Test
   void readOneLineOneRational() throws Exception {
      writeFile("rational_test.txt", "3/2\n");
      List<Rational> rationals = RationalReader.read("rational_test.txt");
      assertThat(rationals).isNotNull().hasSize(1);
      assertThat(rationals.get(0)).extracting("num", "denom").containsExactly(3, 2);

      // writeFile("rational_test.txt", "3\n");
      // rationals = RationalReader.read("rational_test.txt");
      // assertThat(rationals).isNotNull().hasSize(1);
      // assertThat(rationals.get(0)).extracting("num", "denom").containsExactly(3, 1);
   }

   @Test
   void readOneLineSeveralRationals() throws Exception {
      writeFile("rational_test.txt", "1/2 1/3 3/4\n");
      List<Rational> rationals = RationalReader.read("rational_test.txt");
      assertThat(rationals).isNotNull().hasSize(3);
      assertThat(rationals.get(0)).extracting("num", "denom").containsExactly(1, 2);
      assertThat(rationals.get(1)).extracting("num", "denom").containsExactly(1, 3);
      assertThat(rationals.get(2)).extracting("num", "denom").containsExactly(3, 4);
   }

   @Test
   void readSeveralLinesOneRational() throws Exception {
      writeFile("rational_test.txt", "1/2\n1/3\n3/4\n");
      List<Rational> rationals = RationalReader.read("rational_test.txt");
      assertThat(rationals).isNotNull().hasSize(3);
      assertThat(rationals.get(0)).extracting("num", "denom").containsExactly(1, 2);
      assertThat(rationals.get(1)).extracting("num", "denom").containsExactly(1, 3);
      assertThat(rationals.get(2)).extracting("num", "denom").containsExactly(3, 4);
   }

   @Test
   void readSeveralLines() throws Exception {
      writeFile("rational_test.txt", "1/2 3/4\n5/6 7/8 9/10\n11/12 13/14");
      List<Rational> rationals = RationalReader.read("rational_test.txt");
      assertThat(rationals.get(0)).extracting("num", "denom").containsExactly(1, 2);
      assertThat(rationals.get(1)).extracting("num", "denom").containsExactly(3, 4);
      assertThat(rationals.get(2)).extracting("num", "denom").containsExactly(5, 6);
      assertThat(rationals.get(3)).extracting("num", "denom").containsExactly(7, 8);
      assertThat(rationals.get(4)).extracting("num", "denom").containsExactly(9, 10);
      assertThat(rationals.get(5)).extracting("num", "denom").containsExactly(11, 12);
      assertThat(rationals.get(6)).extracting("num", "denom").containsExactly(13, 14);
   }

   @Test
   void readRationalIntegerMix() throws Exception {
      writeFile("rational_test.txt", "1/2 3 4\n5 6 7/8 9/10\n11 12 13/14");
      List<Rational> rationals = RationalReader.read("rational_test.txt");
      int i = 0;
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(1, 2);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(3, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(4, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(5, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(6, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(7, 8);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(9, 10);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(11, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(12, 1);
      assertThat(rationals.get(i++)).extracting("num", "denom").containsExactly(13, 14);
   }

   // helper method

   private File writeFile(String fileName, String fileContent) throws IOException {
      File file = new File(fileName);
      PrintWriter out = new PrintWriter(new FileWriter(fileName, false));
      out.write(fileContent);
      out.close();
      file.deleteOnExit();
      return file;
   }
}
