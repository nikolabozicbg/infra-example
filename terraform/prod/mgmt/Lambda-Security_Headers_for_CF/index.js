"use strict";
exports.handler = (event, context, callback) => {
	//Get contents of response
	const response = event.Records[0].cf.response;
	const headers = response.headers;

	//Set new headers
	headers["strict-transport-security"] = [
		{
			key: "Strict-Transport-Security",
			value: "max-age=63072000; includeSubdomains; preload",
		},
	];
	headers["content-security-policy"] = [
		{
			key: "Content-Security-Policy",
			value: "default-src 'self' https://api.transfast.pannovate.net; style-src 'self' 'unsafe-inline'; font-src 'self' https://fonts.gstatic.com; img-src 'self' https://s3-bucket-transfast-prod-syllo-uploads.s3.eu-west-1.amazonaws.com/ blob: data: https://www.googletagmanager.com/; script-src 'self' blob: 'unsafe-inline' https://www.googletagmanager.com/; object-src 'none'; worker-src 'self' blob:;",
		},
	];
	headers["x-content-type-options"] = [
		{ key: "X-Content-Type-Options", value: "nosniff" },
	];
	headers["x-frame-options"] = [{ key: "X-Frame-Options", value: "DENY" }];
	headers["x-xss-protection"] = [
		{ key: "X-XSS-Protection", value: "1; mode=block" },
	];
	headers["referrer-policy"] = [
		{ key: "Referrer-Policy", value: "same-origin" },
	];

	//Return modified response
	callback(null, response);
};
