# Create an IAM role for the Step Function
resource "aws_iam_role" "example" {
  name = "example-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.example.name
}

# Allow the Step Function to execute the Glue jobs
resource "aws_iam_policy" "example" {
  name        = "step-function-example-policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ]
        Resource = [
          "arn:aws:glue:us-east-1:*:job/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example2" {
  policy_arn = aws_iam_policy.example.arn
  role       = aws_iam_role.example.name
}

resource "aws_sfn_state_machine" "example" {
  name = "example-state-machine"
  role_arn = aws_iam_role.example.arn

  definition = <<EOF
{
  "Comment": "Example Step Function",
  "StartAt": "Parallel_stg",
  "States": {
    "Parallel_stg": {
      "Type": "Parallel",
      "Next": "Pass_stg",
      "Branches": [
        {
          "StartAt": "Pass_toolkit_jdbc",
          "States": {
            "Pass_toolkit_jdbc": {
              "Type": "Pass",
              "Next": "Map_stg_jdbc"
            },
            "Map_stg_jdbc": {
              "Type": "Map",
              "ItemsPath": "$.target_glue_table_raw.sap_tables",
              "MaxConcurrency": 0,
              "Iterator": {
                "StartAt": "STG_jdbc",
                "States": {
                  "STG_jdbc": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::glue:startJobRun.sync",
                    "InputPath": "$",
                    "Parameters": {
                      "JobName": "cmontoya-etl-example-stg",
                      "Arguments": {
                        "--table.$": "$"
                      }
                    },
                    "ResultSelector": {
                      "Metrics": {
                        "JobName.$": "$.JobName",
                        "ExecutionTime.$": "$.ExecutionTime",
                        "Id.$": "$.Id",
                        "Process.$": "$.Arguments.--table"
                      }
                    },
                    "ResultPath": "$",
                    "End": true
                  }
                }
              },
              "ResultPath": "$.Results",
              "End": true
            }
          }
        },
        {
          "StartAt": "Pass_toolkit_sftp",
          "States": {
            "Pass_toolkit_sftp": {
              "Type": "Pass",
              "Next": "Map_stg_sftp"
            },
            "Map_stg_sftp": {
              "Type": "Map",
              "ItemsPath": "$.target_glue_table_raw.pos_tables",
              "MaxConcurrency": 0,
              "Iterator": {
                "StartAt": "STG_sftp",
                "States": {
                  "STG_sftp": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::glue:startJobRun.sync",
                    "InputPath": "$",
                    "Parameters": {
                      "JobName": "cmontoya-etl-example-stg",
                      "Arguments": {
                        "--table.$": "$"
                      }
                    },
                    "ResultSelector": {
                      "Metrics": {
                        "JobName.$": "$.JobName",
                        "ExecutionTime.$": "$.ExecutionTime",
                        "Id.$": "$.Id",
                        "Process.$": "$.Arguments.--table"
                      }
                    },
                    "ResultPath": "$",
                    "End": true
                  }
                }
              },
              "ResultPath": "$.Results",
              "End": true
            }
          }
        }
      ],
      "InputPath": "$"
    },
    "Pass_stg": {
      "Type": "Pass",
      "InputPath": "$$.Execution.Input",
      "Next": "Map_mst"
    },
    "Map_mst": {
      "Type": "Map",
      "ItemsPath": "$.target_glue_table_mst",
      "MaxConcurrency": 0,
      "Iterator": {
        "StartAt": "MST",
        "States": {
          "MST": {
            "Type": "Task",
            "Resource": "arn:aws:states:::glue:startJobRun.sync",
            "InputPath": "$",
            "Parameters": {
              "JobName": "cmontoya-etl-example-mst",
              "Arguments": {
                "--table.$": "$"
              }
            },
            "ResultSelector": {
              "Metrics": {
                "JobName.$": "$.JobName",
                "ExecutionTime.$": "$.ExecutionTime",
                "Id.$": "$.Id",
                "Process.$": "$.Arguments.--table"
              }
            },
            "ResultPath": "$",
            "End": true
          }
        }
      },
      "ResultPath": "$.Results",
      "Next": "Pass_mst"
    },
    "Pass_mst": {
      "Type": "Pass",
      "Next": "Map_dmt"
    },
    "Map_dmt": {
      "Type": "Map",
      "ItemsPath": "$.target_glue_table_dmt",
      "MaxConcurrency": 0,
      "Iterator": {
        "StartAt": "DMT",
        "States": {
          "DMT": {
            "Type": "Task",
            "Resource": "arn:aws:states:::glue:startJobRun.sync",
            "InputPath": "$",
            "Parameters": {
              "JobName": "cmontoya-etl-example-dmt",
              "Arguments": {
                "--table.$": "$"
              }
            },
            "ResultSelector": {
              "Metrics": {
                "JobName.$": "$.JobName",
                "ExecutionTime.$": "$.ExecutionTime",
                "Id.$": "$.Id",
                "Process.$": "$.Arguments.--table"
              }
            },
            "ResultPath": "$",
            "End": true
          }
        }
      },
      "ResultPath": "$.Results",
      "Next": "Pass_dmt"
    },
    "Pass_dmt": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF
}
