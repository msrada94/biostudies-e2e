package listener

import org.junit.ClassRule
import org.junit.platform.launcher.TestExecutionListener
import org.junit.platform.launcher.TestPlan
import org.testcontainers.containers.DockerComposeContainer
import org.testcontainers.containers.wait.strategy.Wait
import test.common.ContextVariables
import java.io.File
import kotlin.io.path.createDirectory
import kotlin.io.path.createTempDirectory
import kotlin.io.path.pathString

class TestListener : TestExecutionListener {
    override fun testPlanExecutionStarted(testPlan: TestPlan) {
        biostudiesEnv.start()
        ContextVariables["ENV_URL"] = "http://localhost:${biostudiesEnv.getServicePort("biostudies", 8081)}"
        ContextVariables["ENV_FTP"] = "$biostudiesBaseFolder/ftp"
    }

    override fun testPlanExecutionFinished(testPlan: TestPlan) {
        biostudiesEnv.stop()
    }

    private companion object {
        val biostudiesBaseFolder = biostudiesBaseFolder()
        val biostudiesEnv = environment(biostudiesBaseFolder)

        @JvmStatic
        @ClassRule
        fun environment(directoriesPath: String): DockerComposeContainer<*> =
            DockerComposeContainer(File("src/test/resources/docker/docker-compose.yml"))
                .withExposedService("mysql", 3308, Wait.forHealthcheck())
                .withExposedService("mongo", 27017, Wait.forHealthcheck())
                .withExposedService("rabbitmq", 15673, Wait.forHealthcheck())
                .withExposedService("rabbitmq", 5673, Wait.forHealthcheck())
                .withExposedService("biostudies", 8081, Wait.forListeningPort())
                .withEnv("ENV_DIRECTORIES", directoriesPath)

        fun biostudiesBaseFolder(): String =
            createTempDirectory("temp").resolve("directories").createDirectory().pathString
    }
}
