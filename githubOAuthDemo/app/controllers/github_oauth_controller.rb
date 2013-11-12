require 'temboo'
require 'Library/GitHub'

class GithubOauthController < ApplicationController

	# Temboo account name and application key; get these from 
	# https://www.temboo.com/account/appkeys/ (after registering a free account)
	TEMBOO_ACCOUNT_NAME = 'xxxxxxx'
	TEMBOO_APP_KEY_NAME = 'xxxxxxx'
	TEMBOO_APP_KEY = 'xxxxxxx'

	# Github application ID and secret. Make sure to register the app following the
	# instructions at https://www.temboo.com/library/Library/GitHub/OAuth/
	GITHUB_CLIENT_ID = 'xxxxxxx'
	GITHUB_CLIENT_SECRET = 'xxxxxxx'

	# The location of the 'finalize OAuth' controller for this app
	FINALIZE_OAUTH_CONTROLLER = "http://0.0.0.0:3000/github_oauth/finalizeOAuth"

	TEMBOO_SESSION = TembooSession.new(TEMBOO_ACCOUNT_NAME, TEMBOO_APP_KEY_NAME, TEMBOO_APP_KEY)

	def index
		# Nothing to do here; index is just a static HTML page
	end

	def initializeOAuth
		# Instantiate the Initialize OAuth choreo
		initializeOAuthChoreo = GitHub::OAuth::InitializeOAuth.new(TEMBOO_SESSION)

		# Get an InputSet object for the choreo
		initializeOAuthInputs = initializeOAuthChoreo.new_input_set()

		# Set inputs
		initializeOAuthInputs.set_ClientID(GITHUB_CLIENT_ID)
		initializeOAuthInputs.set_ForwardingURL(FINALIZE_OAUTH_CONTROLLER)

		# Execute Choreo
		initializeOAuthResults = initializeOAuthChoreo.execute(initializeOAuthInputs)

		@callbackID = initializeOAuthResults.get_CallbackID()
		@authorizationURL = initializeOAuthResults.get_AuthorizationURL()

		# Store the callback ID in a cookie; we'll need this during
		# the finalizeOAuth process
		cookies[:tembooCallbackID] = @callbackID

		# Redirect the user to the authorization URL
		redirect_to @authorizationURL
	end

	def finalizeOAuth
		# Grab the callback ID out of the cookie
		@retrievedCallbackID = cookies[:tembooCallbackID]

		# Instantiate the Choreo, using a previously instantiated TembooSession object,
		finalizeOAuthChoreo = GitHub::OAuth::FinalizeOAuth.new(TEMBOO_SESSION)

		# Get an InputSet object for the choreo
		finalizeOAuthInputs = finalizeOAuthChoreo.new_input_set()

		# Set inputs
		finalizeOAuthInputs.set_CallbackID(@retrievedCallbackID)
		finalizeOAuthInputs.set_ClientID(GITHUB_CLIENT_ID)
		finalizeOAuthInputs.set_ClientSecret(GITHUB_CLIENT_SECRET)

		# Execute Choreo
		finalizeOAuthResults = finalizeOAuthChoreo.execute(finalizeOAuthInputs)

		# Get the GitHub access token
		@accessToken = finalizeOAuthResults.get_AccessToken();

		# Store the access token in a cookie, for reuse
		cookies[:githubAccessToken] = @accessToken
	end
end
