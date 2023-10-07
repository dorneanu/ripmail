workspace {
  name "Self-Destructing Email Service"
  description "The sofware architecture of the self-destructing email servic"

  model {
    u = person "Customer"
    s = softwareSystem "Software System" {
      webapp = container "Web Application" "" "Spring?"
      database = container "Database" "" "RDBS"
    }

    // Deployments
    live = deploymentEnvironment "Live" {
      // AWS
      deploymentNode "Amazon Web Services" {
        tags "Amazon Web Services - Cloud"

        // Which region
        deploymentNode "eu-central-1" {
          tags "Amazon Web Services - Region"

          // -------------------------------------------------------------------
          // Organizational Unit: DevOps
          // -------------------------------------------------------------------
          deploymentNode "OU-DevOps" {
            tags "Amazon Web Services - AWS Organizations Organizational Unit"

            deploymentNode "acc-devops-prod" {
              tags "Amazon Web Services - AWS Organizations Account"

              infrastructureNode "Gitlab Server" {
                tags "Amazon Web Services - EC2"
              }

            }
          }
          
          // -------------------------------------------------------------------
          // Organizational Unit: Tech
          // -------------------------------------------------------------------
          deploymentNode "OU-Tech" {
            tags "Amazon Web Services - AWS Organizations Organizational Unit"

            deploymentNode "acc-tech-prod" {
              tags "Amazon Web Services - AWS Organizations Account"

              infrastructureNode "EKS Cluster" {
                tags = "Amazon Web Services - EKS Cloud"
              }
            }
          }

          // -------------------------------------------------------------------
          // Organizational Unit: Security
          // -------------------------------------------------------------------
          deploymentNode "OU-Security" {
            tags "Amazon Web Services - AWS Organizations Organizational Unit"

            deploymentNode "acc-security-logging" {
              tags "Amazon Web Services - AWS Organizations Account"

              s3_logging = infrastructureNode "S3 Bucket" {
                tags "Amazon Web Services - Simple Storage Service"
              }

              infrastructureNode "CloudWatch Logs" {
                tags "Amazon Web Services - CloudWatch Logs"
              }
            }

            deploymentNode "acc-security-monitoring" {
              tags "Amazon Web Services - AWS Organizations Account"

              infrastructureNode "CloudWatch" {
                tags "Amazon Web Services - CloudWatch Alarm"
              }
            }
          }
        }  
      }
    }
  }

  views {
    // System context
    systemContext s "SystemContext" {
      include *
      description "The system context diagram for the self-destructing mail service"
    }

    // Container context
    container s "Containers" {
      include *
      description "The container diagram for the self-destructing mail service"
    }

    // Deployment live
    deployment s live "LiveDeployment"  {
      include *
      // autoLayout lr
      description "An example live deployment for the self-destructing email service"
    }

    // Themes
    // You can combine multiple themes!
    theme https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
    theme https://static.structurizr.com/themes/kubernetes-v0.3/theme.json

    // Extra Styling
    styles {
      element "Person" {
        color #ffffff
        fontSize 22
        shape Person
      }
    }

  }
}
