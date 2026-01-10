📌 상황

쇼핑몰 데이터베이스가 있고, 기획팀에서 이런 요청이 왔어요.

“2024년 12월에 매출이 가장 높은 상품 TOP 3를 알려주세요.”


📂 테이블 구조
orders (
  order_id     INT,
  user_id      INT,
  order_date   DATE
)

order_items (
  order_id     INT,
  product_id   INT,
  price        INT,
  quantity     INT
)

📌 매출 = price * quantity

#내가 생각한 쿼리
SELECT oi.product_id,SUM(oi.price * oi.quantity) AS total_sales
FROM order_items oi
JOIN orders o
    ON o.order_id = oi.order_id
GROUP BY oi.product_id
HAVING o.order_date >= '2024-12-01'
   AND o.order_date < '2025-01-01';
ORDER BY total_sales DESC
LIMIT 3;

* where 안쓰고 having에 조건을 건 이유 : 상품별로 모은 후 날짜로 걸고 싶어서 즉, 의도해서 쓴거임
하지만 where에 조건을 걸어야한다.
1. having은 집계함수를 쓸 수 없는 where 때문에 쓰기 위해 만들어졌고
2. 실행도 where이 먼저 조회된다.
3. where에 날짜 조건 없이 쿼리짜면 실무에서는 10년치 데이터 다 가지고와서 엄청 느린 결과를 볼 수 있고, 성능이 안 좋아진다.
4. 인덱스 안탄다.

❓ HAVING 쓰면 왜 order_date 인덱스를 못 타나?

#핵심 한 줄
HAVING은 “이미 다 모아서(GROUP BY) 계산한 뒤” 필터링하기 때문에
행(row) 단위 인덱스를 사용할 수 없음


인덱스는 언제 타냐?

WHERE 절에서, row를 읽기 전에

WHERE o.order_date >= '2024-12-01'


인덱스: “이 날짜 범위에 해당하는 row 위치 알려줌”

HAVING: “이미 요리 다 한 뒤, 접시 버리기”


#답
SELECT
    oi.product_id,
    SUM(oi.price * oi.quantity) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_date >= '2024-12-01'
  AND o.order_date < '2025-01-01'
GROUP BY oi.product_id
ORDER BY total_sales DESC
LIMIT 3;
