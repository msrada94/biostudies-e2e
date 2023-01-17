package test.steps

import io.cucumber.datatable.DataTable
import io.cucumber.java.en.Given
import test.common.ContextVariables

class SetupSteps {
    @Given("the setup information")
    fun theSetupInformation(table: DataTable) {
        ContextVariables.putAll(table.asMap().mapValues {
            ContextVariables.getString(it.value)
        }
        )
    }
}
