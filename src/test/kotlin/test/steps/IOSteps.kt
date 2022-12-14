package test.steps

import io.cucumber.java.en.And
import org.assertj.core.api.Assertions.assertThat
import org.skyscreamer.jsonassert.JSONAssert
import org.skyscreamer.jsonassert.JSONCompareMode
import org.springframework.core.io.FileSystemResource
import test.common.ContextVariables
import test.common.ContextVariables.getString
import java.io.File
import java.nio.file.Files
import kotlin.io.path.createFile
import kotlin.io.path.writeText

class IOSteps {
    private val tempFile = Files.createTempDirectory("tempFolder").toFile()

    @And("the file {string} has content:")
    fun assertFileHasContent(fileName: String, expectedContent: String) {
        val file = File(getString(fileName))
        require(file.exists())

        assertThat(file.readText()).isEqualTo(expectedContent)
    }

    @And("the file {string} has JSON content:")
    fun assertFileHasJSONContent(fileName: String, expectedContent: String) {
        val file = File(getString(fileName))
        require(file.exists())

        JSONAssert.assertEquals("invalid attribute json", file.readText(), expectedContent, JSONCompareMode.LENIENT)
    }

    @And("the file {string} named {string} with content")
    fun createFileWithContent(variableName: String, fileName: String, content: String) {
        val file = tempFile.toPath().resolve(fileName).createFile().apply { writeText(content) }

        ContextVariables[variableName] = FileSystemResource(file.toFile())
    }
}
