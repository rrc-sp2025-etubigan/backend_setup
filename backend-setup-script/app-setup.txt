import express, { Express } from "express";
import morgan from "morgan";

// import the item routes from the new routes file
//import placeholderRoute from "./api/v1/routes/placeholderRoute.ts";

const app: Express = express();

app.use(express.json());
app.use(morgan("combined"));

// Route handler for items
//app.use("/api/v1", placeholderRoute);

// Export the app
export default app;
