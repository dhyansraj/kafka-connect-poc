DROP TABLE IF EXISTS digitalassets.orders;

CREATE TABLE digitalassets.orders (
    order_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id VARCHAR(100) NOT NULL,
    supplier_id VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    items integer NOT NULL,
    price NUMERIC(10,3) NOT NULL,
    weight NUMERIC(10,3) NOT NULL,
    automated_email boolean DEFAULT true
);


ALTER TABLE digitalassets.orders OWNER TO superdbuser;
