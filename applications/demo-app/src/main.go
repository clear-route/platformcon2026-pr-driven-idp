package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)




const defaultPort = "3000"

var page = template.Must(template.New("home").Parse(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Demo App</title>
  <style>
    body {
      align-items: center;
      background: #f7f8fa;
      color: #17202a;
      display: flex;
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      justify-content: center;
      margin: 0;
      min-height: 100vh;
    }
    main {
      max-width: 42rem;
      padding: 2rem;
    }
    h1 {
      font-size: clamp(2rem, 7vw, 4rem);
      line-height: 1;
      margin: 0 0 1rem;
    }
    p {
      font-size: 1.125rem;
      line-height: 1.6;
      margin: 0.5rem 0;
    }
    code {
      background: #e8edf2;
      border-radius: 0.375rem;
      padding: 0.125rem 0.375rem;
    }
  </style>
</head>
<body>
  <main>
    <h1>Hello from demo app</h1>
    <p>{{ .Message }}</p>
    <p><code>BUILD_BRANCH={{ .BuildBranch }}</code></p>
  </main>
</body>
</html>
`))

type pageData struct {
	Message     string
	BuildBranch string
}

func main() {
	port := envOrDefault("PORT", defaultPort)
	buildBranch := envOrDefault("BUILD_BRANCH", "unknown")

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}

		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		err := page.Execute(w, pageData{
			Message:     "This tiny web app is running and ready for PR-driven previews.",
			BuildBranch: buildBranch,
		})
		if err != nil {
			log.Printf("render page: %v", err)
		}
	})
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = fmt.Fprintln(w, "ok")
	})

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("hello from demo app listening on port %s", port)
	log.Printf("BUILD_BRANCH=%s", buildBranch)

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server failed: %v", err)
	}
}

func envOrDefault(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}
