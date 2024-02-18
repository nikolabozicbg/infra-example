// Grafana k6 is an open-source load testing tool that makes performance testing easy and
// productive for engineering teams. k6 is free, developer-centric, and extensible.

// Using k6, you can test the reliability and performance of your systems and catch
// performance regressions and problems earlier. k6 will help you to build resilient and
// performant applications that scale.

// https://k6.io/docs/

import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = "https://api.transfast.stage.pannovate.net";

// NOTE: In Options either use Stages or Scenarios.
export const options = {
	// vus: 10,
	// stages: [
	// 	{ duration: "30s", target: 20 },
	// 	{ duration: "1m30s", target: 10 },
	// ],
	scenarios: {
		example_scenario: {
			// name of the executor to use
			executor: "shared-iterations",

			// common scenario configuration
			startTime: "0s",
			// gracefulStop: "5s",
			env: { EXAMPLEVAR: "testing" },
			tags: { example_tag: "testing" },

			// executor-specific configuration
			vus: 10,
			iterations: 200,
			maxDuration: "10s",
		},
		another_scenario: {
			// name of the executor to use
			executor: "shared-iterations",

			// common scenario configuration
			startTime: "5s",
		},
	},
};

export default function () {
	const res = http.get(BASE_URL + "/front");
	check(res, { "status was 200": (r) => r.status == 200 });
	sleep(1);
}
