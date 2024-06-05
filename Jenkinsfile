pipeline {
  agent any
  stages {
    stage('') {
      steps {
        dir(path: 's3_website') {
          sh 'terraform init'
          sh 'terraform plan'
          sh 'terraform apply -auto-approve'
        }

      }
    }

  }
  environment {
    AWS_ACCESS_KEY_ID = 'credentials(lab2-cred)'
    AWS_SECRET_ACCESS_KEY = 'credentials(lab2-cred)'
  }
}