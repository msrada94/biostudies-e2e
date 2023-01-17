Feature: 5 Resubmit submission.

  Shows how the system behaves when a resubmitted an existing submission.
  The scenarios are considered on files changes.

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

  Scenario: 5-1 resubmit existing submission
    # UPLOAD FILES TO BASE FOLDER
    Given the file "fileList" named "file-list.tsv" with content
    """
    Files	Type
    a/fileFileList.pdf	inner
    a	folder

    """
    * the file "sectionFile" named "file section.doc" with content
    """
    Section file content.
    """
    * the file "subSectionFile" named "fileSubSection.txt" with content
    """
    Subsection file content.
    """
    And a http request with form-data body:
      | files | $fileList | $sectionFile | $subSectionFile |
    * url path "$environmentUrl/files/user"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    # UPLOAD FILE TO "a" FOLDER
    Given the file "fileInFileList" named "fileFileList.pdf" with content
    """
    File in file list content.
    """
    And a http request with form-data body:
      | files | $fileInFileList |
    * url path "$environmentUrl/files/user/a"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    # SUBMIT SUBMISSION
    Given a http request with body:
    """
    Submission	S-BSST500
    Title	Simple Submission With Files
    ReleaseDate	2020-01-25

    Study
    Type	Experiment
    File List	file-list.tsv

    File	file section.doc
    Type	test

    Experiment	Exp1
    Type	Subsection

    File	fileSubSection.txt
    Type	Attached

    """
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token                       |
      | Submission_Type | text/plain                   |
      | Content-Type    | text/plain                   |
      | Accept          | text/plain, application/json |
    When request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST500",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Simple Submission With Files"
      }, {
        "name" : "ReleaseDate",
        "value" : "2020-01-25"
      } ],
      "section" : {
        "type" : "Study",
        "attributes" : [ {
          "name" : "Type",
          "value" : "Experiment"
        }, {
          "name" : "File List",
          "value" : "file-list.json"
        } ],
        "files" : [ {
          "path" : "file section.doc",
          "size" : 21,
          "attributes" : [ {
            "name" : "Type",
            "value" : "test"
          } ],
          "type" : "file"
        } ],
        "subsections" : [ {
          "accno" : "Exp1",
          "type" : "Experiment",
          "attributes" : [ {
            "name" : "Type",
            "value" : "Subsection"
          } ],
          "files" : [ {
            "path" : "fileSubSection.txt",
            "size" : 24,
            "attributes" : [ {
              "name" : "Type",
              "value" : "Attached"
            } ],
            "type" : "file"
          } ]
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/file section.doc" has content:
    """
    Section file content.
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/fileSubSection.txt" has content:
    """
    Subsection file content.
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/a/fileFileList.pdf" has content:
    """
    File in file list content.
    """

    # UPLOAD CHANGED FILE
    Given the file "subSectionFile" named "fileSubSection.txt" is modified with the new content
    """
    Subsection file NEW content.
    """
    And a http request with form-data body:
      | files | $subSectionFile |
    * url path "$environmentUrl/files/user"
    * http method "POST"
    * headers
      | X-Session-Token | $token              |
      | Content-Type    | multipart/form-data |
    When multipart request is performed
    Then http status code "200" is returned

    # RE SUBMIT
    Given a http request with body:
    """
    Submission	S-BSST500
    Title	Simple Submission With Files
    ReleaseDate	2020-01-25

    Study
    Type	Experiment
    File List	file-list.tsv

    File	file section.doc
    Type	test

    Experiment	Exp1
    Type	Subsection

    File	fileSubSection.txt
    Type	Attached

    """
    * url path "$environmentUrl/submissions"
    * http method "POST"
    * headers
      | X-Session-Token | $token                       |
      | Submission_Type | text/plain                   |
      | Content-Type    | text/plain                   |
      | Accept          | text/plain, application/json |
    When request is performed
    Then http status code "200" is returned with body:
    """
    {
      "accno" : "S-BSST500",
      "attributes" : [ {
        "name" : "Title",
        "value" : "Simple Submission With Files"
      }, {
        "name" : "ReleaseDate",
        "value" : "2020-01-25"
      } ],
      "section" : {
        "type" : "Study",
        "attributes" : [ {
          "name" : "Type",
          "value" : "Experiment"
        }, {
          "name" : "File List",
          "value" : "file-list.json"
        } ],
        "files" : [ {
          "path" : "file section.doc",
          "size" : 21,
          "attributes" : [ {
            "name" : "Type",
            "value" : "test"
          } ],
          "type" : "file"
        } ],
        "subsections" : [ {
          "accno" : "Exp1",
          "type" : "Experiment",
          "attributes" : [ {
            "name" : "Type",
            "value" : "Subsection"
          } ],
          "files" : [ {
            "path" : "fileSubSection.txt",
            "size" : 28,
            "attributes" : [ {
              "name" : "Type",
              "value" : "Attached"
            } ],
            "type" : "file"
          } ]
        } ]
      },
      "type" : "submission"
    }
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/file section.doc" has content:
    """
    Section file content.
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/fileSubSection.txt" has content:
    """
    Subsection file NEW content.
    """
    And the file "$ftpUrl/S-BSST/500/S-BSST500/Files/a/fileFileList.pdf" has content:
    """
    File in file list content.
    """
