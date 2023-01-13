Feature:

  Considers submissions and resubmissions with different source files as: user space, group, fire, bypassing files with fire.

  Background:
    Given the setup information
      | environmentUrl | http://localhost:8080        |
      | ftpUrl         | /Users/miguel/Biostudies/ftp |
      | userName       | admin_user@ebi.ac.uk         |
      | userPassword   | 123456                       |
    * the variable "storageMode" with value "NFS"
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

  Scenario: resubmission with SUBMISSION file source as priority over USER SPACE
    # UPLOAD FILES
    Given the file "file" named "File1.txt" with content
    """
    content file 1
    """
    * the file "fileListFile" named "File2.txt" with content
    """
    content file 2
    """
    And a http request with form-data body:
      | files | $file | $fileListFile |
    * url path "$environmentUrl/files/user"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    # SUBMIT A SUBMISSION
    Given the file "fileList" named "FileList.tsv" with content
    """
    Files	GEN
    File2.txt	ABC
    """
    * the variable "submission" with value
    """
    Submission	S-BSST600
    Title	Preferred Source Submission
    ReleaseDate	2021-02-12

    Study	SECT-001
    Title	Root Section
    File List	FileList.tsv

    File	File1.txt

    """
    And a http request with form-data body:
      | files       | $fileList    |
      | submission  | $submission  |
      | storageMode | $storageMode |
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token                       |
      | Content-Type    | multipart/form-data          |
      | Submission_Type | text/plain                   |
      | Accept          | text/plain, application/json |
    When multipart request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST600",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Preferred Source Submission"
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
          "value" : "FileList.json"
        } ],
        "files" : [ {
          "path" : "File1.txt",
          "size" : 14,
          "type" : "file"
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/File1.txt" has content:
    """
    content file 1
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/File2.txt" has content:
    """
    content file 2
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.tsv" has content:
    """
    Files	GEN
    File2.txt	ABC

    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.xml" has content:
    """
    <?xml version='1.0' encoding='UTF-8'?><table><file size="14">
      <path>File2.txt</path>
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
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.json" has JSON content:
    """
    [
      {
        "path": "File2.txt",
        "size": 14,
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

    # UPLOAD CHANGED FILE
    Given the file "file" named "File1.txt" with content
    """
    content file 1 updated
    """
    And a http request with form-data body:
      | files | $file |
    * url path "$environmentUrl/files/user"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    # RE SUBMIT
    Given the variable "submission" with value
    """
    Submission	S-BSST600
    Title	Preferred Source Submission
    ReleaseDate	2021-02-12

    Study	SECT-001
    Title	Root Section
    File List	FileList.json

    File	File1.txt

    """
    And the variable "SUBMISSION" with value "SUBMISSION"
    And the variable "USER_SPACE" with value "USER_SPACE"
    And a http request with form-data body:
      | preferredSources | $SUBMISSION  | $USER_SPACE |
      | submission       | $submission  |             |
      | storageMode      | $storageMode |             |
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token                       |
      | Content-Type    | multipart/form-data          |
      | Submission_Type | text/plain                   |
      | Accept          | text/plain, application/json |
    When multipart request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST600",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Preferred Source Submission"
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
          "value" : "FileList.json"
        } ],
        "files" : [ {
          "path" : "File1.txt",
          "size" : 14,
          "type" : "file"
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/File1.txt" has content:
    """
    content file 1
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/File2.txt" has content:
    """
    content file 2
    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.tsv" has content:
    """
    Files	GEN
    File2.txt	ABC

    """
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.xml" has content:
    """
    <?xml version='1.0' encoding='UTF-8'?><table><file size="14">
      <path>File2.txt</path>
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
    And the file "$ftpUrl/S-BSST/600/S-BSST600/Files/FileList.json" has JSON content:
    """
    [
      {
        "path": "File2.txt",
        "size": 14,
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
