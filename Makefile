STAGE := $(shell awk -F "=" '/stage/ {print $$2}' config)
REGION := $(shell awk -F "=" '/region/ {print $$2}' config)
#ROLE := $(shell awk -F "=" '/role/ {print $$2}' config)
ROLE := $(NAME)
RESTID := $(shell) 

NAME := loan_calculator
NAME_LAMBDA := $(NAME)
#NAME_LAMBDA := $(STAGE)-$(NAME)

ZIP := $(NAME).zip

SLS_PARAMS := \
	--stage $(STAGE) \
	--region $(REGION) \
	--lambdaName $(STAGE)-$(NAME) \
	--config sls/serverless.yml

default: install package deploy
deploy: package cf aws
deploy-no-package: cf aws
update: package aws

install:
	@echo "-- Installing serverless plugins..."
	@npm install serverless-fix-apigw-int@1.0.0
	@npm install serverless-plugin-git-variables
	@echo "-- Installion complete."

package:
	@echo "-- Packaging $(NAME) for upload to AWS Lambda..."
	@pip3 install --no-deps -r ./requirements.txt --target ./deps
#	@zip -r $(ZIP) ./deps/*
#	@zip -r $(ZIP) ./endpoints/*
#	@zip -r $(ZIP) ./lib/*
#	@zip -g $(ZIP) $(NAME).py config
#	@zip -g $(ZIP) __init__.py
	@echo "-- Packaging complete!"

cf:
	@echo "-- Deploying CloudFormation stack..."
	@serverless deploy $(SLS_PARAMS)
	@echo "-- Deployment complete!"	

aws:
	@echo "-- Updating AWS Lambda function..."
	aws lambda update-function-code --function-name $(NAME_LAMBDA) --region $(REGION) --zip-file fileb://$(ZIP)
	@echo "-- Update complete."

delete-cf-stack:
	@echo "-- DELETING CF STACK..."
	@serverless remove $(SLS_PARAMS) 
	@echo "-- DELETE COMPLETE."

clean:
	@rm -rf $(ZIP) node_modules/ deps/
	@echo "-- Directory cleaned."
