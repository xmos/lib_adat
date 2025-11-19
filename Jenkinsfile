// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.43.3') _

getApproval()

pipeline {

  agent none

  options {
    timestamps()
    buildDiscarder(xmosDiscardBuildSettings())
    skipDefaultCheckout()
  }
  parameters {
    string(
      name: 'TOOLS_VERSION',
      defaultValue: '15.3.1',
      description: 'The XTC tools version'
    )
    string(
      name: 'XMOSDOC_VERSION',
      defaultValue: 'v8.0.0',
      description: 'The xmosdoc version'
    )
    string(
        name: 'INFR_APPS_VERSION',
        defaultValue: 'v3.2.0',
        description: 'The infr_apps version'
    )
  }

  stages {
    stage('🏗️ Build and test') {
      agent {
        label 'x86_64 && linux && documentation'
      }

      stages {
        stage('Checkout') {
          steps {
            println "Stage running on: ${env.NODE_NAME}"

            script {
              def (server, user, repo) = extractFromScmUrl()
              env.REPO_NAME = repo
            }

            dir(REPO_NAME){
              checkoutScmShallow()
            }
          }
        }  // Checkout


        stage('Examples build') {
          steps {
            dir("${REPO_NAME}/examples") {
              xcoreBuild()
            }
          }
        }

        stage('Library checks') {
          steps {
            warnError("Repo checks failed") {
              runRepoChecks("${WORKSPACE}/${REPO_NAME}")
            }
          }
        }

        stage('Documentation') {
          steps {
            dir(REPO_NAME) {
              buildDocs()
            }
          }
        }
        
        stage("Archive sandbox") {
          steps {
            archiveSandbox(REPO_NAME)
          }
        }
      } // stages

      post {
        cleanup {
          xcoreCleanSandbox()
        } // cleanup
      } // post
      
    } // stage 'Build and test'
    
    stage('🚀 Release') {
      when {
        expression { triggerRelease.isReleasable() }
      }
      steps {
        triggerRelease()
      }
    }
  }
} // pipeline
