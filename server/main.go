package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func main() {
	productHandler := func(w http.ResponseWriter, req *http.Request) {
		product1 := ProductDTO{Id: 1, Name: "Chicken"}
		product2 := ProductDTO{Id: 2, Name: "Pizza"}
		product3 := ProductDTO{Id: 3, Name: "Pasta"}
		products := []ProductDTO{product1, product2, product3}

		productsJson, err := json.Marshal(products)
		if err != nil {
			log.Fatalf("Failed to marshal response. Resp: %v, Err: %s", products, err)
		}

		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json")
		w.Write(productsJson)
	}

	http.HandleFunc("/products", productHandler)
	log.Println("Listing on port 8000")
	log.Fatal(http.ListenAndServe(":8000", nil))
}

type ProductDTO struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}
