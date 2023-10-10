workspace {
  // See  https://github.com/structurizr/dsl/blob/master/docs/language-reference.md#identifier-scope
  // !identifiers hierarchical

  name "Self-Destructing Email Service"
  description "The sofware architecture of the self-destructing email servic"

  model {
    u = person "Customer"
    group "Self-Destructing Email Service" {
      // Logging keeps track of several events
      logging = softwaresystem "Logging System" "Logs several events related to mail generation" {
        tags "Service API"
      } 
      storage = softwaresystem "Storage System" "Stores encrypted mail content" {
        tags "Database"
      }

      // Backend system responsible for the business logic
      backend = softwaresystem "Backend System" {
        webapplication = container "Web Application"

        // Services/
        // --- Authentication Service
        authService = group "Authentication Service" {
          authAPI = container "Auth Service API" {
            tags "AuthService" "Service API"
          }
          authDB = container "Auth Service Database" {
            tags "AuthService" "Database"
            authAPI -> this "Checks if credentials match"
          }
        } 

        // --- Notification Service
        notificationService = group "Notification Service" {
          notificationAPI = container "Notification API" {
            tags "NotificationService" "Service API"
          } 
        }  

        // --- Email Composition Service
        mailCompositionService = group "Email Composition Service" {
          mailCompositionAPI = container "Email Composition API" {
            tags "EmailCompositionService" "Service API"
          }
          mailDB = container "Email Composition Database" {
            tags "Emailcompositionservice" "Database"
            mailCompositionAPI -> this "Stores metadata of mails"
          }

        }
        // Store mail data and encrypted content
        mailCompositionAPI -> storage "Store mail metadata and content"

        // Notify recipient
        mailCompositionAPI -> notificationAPI "Notify recipient"
        notificationAPI -> mailcompositionAPI "Recipient notified"

        // Log events
        notificationAPI -> logging "Log Email sent event"

        // Use access to web application
        u -> webapplication
        webapplication -> authAPI "Authenticate user"
        webapplication -> mailCompositionAPI "Create mails"
      }        
    }

    s = softwareSystem "Software System" {
      webapp = container "Web Application" "" "Spring?"
      database = container "Database" "" "RDBS"
    }

    // Relationships between people and software systems

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
          ou_tech = deploymentNode "OU-Tech" {
            tags "Amazon Web Services - AWS Organizations Organizational Unit"

            deploymentNode "acc-tech-prod" {
              tags "Amazon Web Services - AWS Organizations Account"

              // EKS control plane
              eks_vpc = deploymentNode "EKS VPC" {
                tags = "Amazon Web Services - VPC Virtual private cloud VPC"

                eks_control_plane = infrastructureNode "EKS Control Plane" {
                  tags = "Amazon Web Services - EKS Cloud"
                }
              }

              // EKS cluster
              workload_vpc = deploymentNode "Workload VPC" {
                tags = "Amazon Web Services - VPC Virtual private cloud VPC"

                // AZ 1
                deploymentNode "Availability Zone 1" {
                  tags = "Amazon Web Services - Region"

                  deploymentNode "Subnet 1" {
                    tags = "Amazon Web Services - VPC VPN Gateway"

                    eks_node_group1 = deploymentNode "EKS Managed Node Group" {
                      tags = "Amazon Web Services - EKS Cloud"

                      eks_node_group1_pod1 = deploymentNode "Pod 1" {
                        tags = "Kubernetes - pod"
                        pod1_authAPI = containerInstance authAPI
                      }

                      eks_node_group1_pod2 = deploymentNode "Pod 2" {
                        tags = "Kubernetes - pod"
                        pod2_mailCompositionAPI = containerInstance mailcompositionAPI
                        pod2_notificationAPI = containerInstance notificationAPI

                      }

                    }
                  }

                }

                // AZ 2
                deploymentNode "Availability Zone 2" {
                  tags = "Amazon Web Services - Region"

                  deploymentNode "Subnet 1" {
                    tags = "Amazon Web Services - VPC VPN Gateway"

                    eks_node_group2 = infrastructureNode "EKS Managed Node Group" {
                      tags = "Amazon Web Services - EKS Cloud"
                    }

                  }
                }
              }

              

              // DynamoDB instances
              dbs = group "Databases" {
                deploymentNode "DB VPC" {
                  tags = "Amazon Web Services - VPC Virtual private cloud VPC"

                  deploymentNode "DynamoDB (Auth)" {
                    tags "Amazon Web Services - DynamoDB"

                    liveUserDB = containerInstance authDB
                  }

                  deploymentNode "DynamoDB (Mails)" {
                    tags "Amazon Web Services - DynamoDB"

                    liveMailDB = containerInstance mailDB
                  }
                }
              }
            }
          }

          // Relationships
          # pod1_authAPI -> liveUserDB 
          # pod1_authAPI -> liveMailDB

          eks_control_plane -> eks_node_group1 "Controls"
          eks_control_plane -> eks_node_group2 "Controls"

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

    // -- Containers -----------------------------------------------------------
    // Backend
    container backend "Containers_All" {
      include *
      autolayout
    }
    // --- Authentication Service 
    container backend "Containers_AuthenticationService" {
      include ->authService->
      autolayout
    }
    // --- Notification Service 
    container backend "Containers_NotificationService" {
      include ->notificationService->
      autolayout
    }
    # // --- Email Composition Service 
    container backend "Containers_MailCompositionService" {
      include ->mailCompositionService->
      autolayout
    }

    // Container context
    # container s "Containers" {
    #   include *
    #   description "The container diagram for the self-destructing mail service"
    # }

    // Workload live
    deployment backend live "WorkloadDeployment" {
      include ->ou_tech->
      description "Deployment of the workload"
    }

    // Deployment live
    deployment backend live "LiveDeployment"  {
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
      element "Service API" {
        shape hexagon
      }
      element "Database" {
        shape cylinder
      }
    }

  }
}
