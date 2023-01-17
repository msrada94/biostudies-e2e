Feature: Submit a submission with a text file

  Background:
    Given the setup information
      | environmentUrl | $ENV_URL             |
      | ftpUrl         | $ENV_FTP             |
      | storageMode    | NFS                  |
      | userName       | admin_user@ebi.ac.uk |
      | userPassword   | 123456               |
    And a http request with body:
      """
      {
        "login":"$userName",
        "password":"$userPassword"
      }
      """
    * header
      | Content-Type | application/json |
    * url path "$environmentUrl/auth/login"
    * http method "POST"
    When request is performed
    Then http status code "200" is returned
    And the JSONPath value "$.sessid" from response is saved into "token"

  Scenario: submit a submission with a file
    Given the file "submissionFile" named "example.txt" with content
    """
      Sample content
    """
    And a http request with form-data body:
      | files | $submissionFile |
    * url path "$environmentUrl/files/user"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    Given a http request with body:
      """
      Submission	S-BSST129
      Title	Sample Submission
      ReleaseDate	2021-02-12

      Study

      File	example.txt
      """
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token     |
      | Submission_Type | text/plain |
      | Content-Type    | text/plain |
    When request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST129",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Sample Submission"
      }, {
        "name" : "ReleaseDate",
        "value" : "2021-02-12"
      } ],
      "section" : {
        "type" : "Study",
        "files" : [ {
          "path" : "example.txt",
          "size" : 16,
          "type" : "file"
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/129/S-BSST129/Files/example.txt" has content:
      """
        Sample content
      """
    And the file "$ftpUrl/S-BSST/129/S-BSST129/S-BSST129.json" has content:
      """
      {
        "accno" : "S-BSST129",
        "attributes" : [ {
          "name" : "Title",
          "value" : "Sample Submission"
        }, {
          "name" : "ReleaseDate",
          "value" : "2021-02-12"
        } ],
        "section" : {
          "type" : "Study",
          "files" : [ {
            "path" : "example.txt",
            "size" : 16,
            "type" : "file"
          } ]
        },
        "type" : "submission"
      }
      """
    And the file "$ftpUrl/S-BSST/129/S-BSST129/S-BSST129.tsv" has content:
      """
      Submission	S-BSST129
      Title	Sample Submission
      ReleaseDate	2021-02-12

      Study

      File	example.txt

      """
    And the file "$ftpUrl/S-BSST/129/S-BSST129/S-BSST129.xml" has content:
      """
      <?xml version='1.0' encoding='UTF-8'?><submission accno="S-BSST129">
        <attributes>
          <attribute>
            <name>Title</name>
            <value>Sample Submission</value>
          </attribute>
          <attribute>
            <name>ReleaseDate</name>
            <value>2021-02-12</value>
          </attribute>
        </attributes>
        <section type="Study">
          <files>
            <file size="16">
              <path>example.txt</path>
              <type>file</type>
            </file>
          </files>
        </section>
      </submission>

      """
