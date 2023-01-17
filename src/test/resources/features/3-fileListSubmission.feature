Feature: 3 Submit submissions with file lists.

  Shows JSON submissions containing different fileList formats.
  Also submission considering empty files list and reusing previous version fileLists.

  Background:
    Given the setup information
      | environmentUrl | http://localhost:8080        |
      | ftpUrl         | /Users/miguel/Biostudies/ftp |
      | storageMode    | NFS                          |
      | userName       | admin_user@ebi.ac.uk         |
      | userPassword   | 123456                       |
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

  Scenario: 3-1 Submit a JSON submission with a TSV file list
    Given the file "fileList" named "fileList.tsv" with content
    """
    Files	GEN
    file4.txt	ABC
    """
    * the file "fileListFile" named "file4.txt" with content
    """
    File content
    """
    * the variable "submission" with value
    """
    {
      "accno": "S-BSST130",
      "attributes": [
        {
          "name": "Title",
          "value": "Test Submission"
        },
        {
          "name": "ReleaseDate",
          "value": "2021-02-12"
        }
      ],
      "section": {
        "accno": "SECT-001",
        "type": "Study",
        "attributes": [
          {
            "name": "Title",
            "value": "Root Section"
          },
          {
            "name": "File List",
            "value": "fileList.tsv"
          }
        ]
      }
    }
    """
    And a http request with form-data body:
      | files       | $fileList    | $fileListFile |
      | submission  | $submission  |               |
      | storageMode | $storageMode |               |
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token                             |
      | Content-Type    | multipart/form-data                |
      | Submission_Type | application/json                   |
      | Accept          | application/json, application/json |

    When multipart request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST130",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Test Submission"
      }, {
        "name" : "ReleaseDate",
        "value" : "2021-02-12"
      } ],
      "section" : {
        "accno" : "SECT-001",
        "type" : "Study",
        "attributes" : [ {
          "name" : "Title",
          "value" : "Root Section"
        }, {
          "name" : "File List",
          "value" : "fileList.json"
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/Files/file4.txt" has content:
    """
    File content
    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/Files/fileList.json" has JSON content:
    """
    [
      {
        "path": "file4.txt",
        "size": 12,
        "attributes": [
          {
            "name": "GEN",
            "value": "ABC"
          }
        ],
        "type": "file"
      }
    ]
    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/Files/fileList.tsv" has content:
    """
    Files	GEN
    file4.txt	ABC

    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/Files/fileList.xml" has content:
    """
    <?xml version='1.0' encoding='UTF-8'?><table><file size="12">
      <path>file4.txt</path>
      <type>file</type>
      <attributes>
        <attribute>
          <name>GEN</name>
          <value>ABC</value>
        </attribute>
      </attributes>
    </file>
    </table>
    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/S-BSST130.json" has content:
    """
    {
      "accno" : "S-BSST130",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Test Submission"
      }, {
        "name" : "ReleaseDate",
        "value" : "2021-02-12"
      } ],
      "section" : {
        "accno" : "SECT-001",
        "type" : "Study",
        "attributes" : [ {
          "name" : "Title",
          "value" : "Root Section"
        }, {
          "name" : "File List",
          "value" : "fileList.json"
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/S-BSST130.tsv" has content:
    """
    Submission	S-BSST130
    Title	Test Submission
    ReleaseDate	2021-02-12

    Study	SECT-001
    Title	Root Section
    File List	fileList.tsv

    """
    And the file "$ftpUrl/S-BSST/130/S-BSST130/S-BSST130.xml" has content:
    """
    <?xml version='1.0' encoding='UTF-8'?><submission accno="S-BSST130">
      <attributes>
        <attribute>
          <name>Title</name>
          <value>Test Submission</value>
        </attribute>
        <attribute>
          <name>ReleaseDate</name>
          <value>2021-02-12</value>
        </attribute>
      </attributes>
      <section accno="SECT-001" type="Study">
        <attributes>
          <attribute>
            <name>Title</name>
            <value>Root Section</value>
          </attribute>
          <attribute>
            <name>File List</name>
            <value>fileList.xml</value>
          </attribute>
        </attributes>
      </section>
    </submission>

    """
