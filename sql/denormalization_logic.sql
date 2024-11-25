

create table Targets_expanded
as
select
			EmployeeID,
			Target,
			full_date as TargetMonth,
			day_of_week,
			ddate,
			month_day,
			TRIM(SUBSTR(month_day, 1, INSTR(month_day, ' ') -1)) AS mmonth,
			TRIM(SUBSTR(month_day, INSTR(month_day, ' ') + 1)) AS dday,
			TRIM(SUBSTR(ddate, INSTR(ddate, ',') + 1)) AS yyear
		from
			(
				SELECT
					EmployeeID,
					Target,
					full_date,
					day_of_week,
					ddate,
					TRIM(SUBSTR(ddate, 1, INSTR(ddate, ',') -1)) AS month_day
				from
					(
						SELECT
							EmployeeID,
							Target,
							full_date,
							TRIM(SUBSTR(full_date, 1, INSTR(full_date, ',') - 1)) AS day_of_week,
							TRIM(SUBSTR(full_date, INSTR(full_date, ',') + 1)) AS ddate
						FROM
							(
								select
									EmployeeID,
									Target,
									TargetMonth as full_date
								from
									Targets
							)
					)
			)
	
;

create table sales_expanded
as
select
			*
			,TRIM(SUBSTR(month_day, 1, INSTR(month_day, ' ') -1)) AS order_month
			,TRIM(SUBSTR(month_day, INSTR(month_day, ' ') + 1)) AS order_day
			,TRIM(SUBSTR(ddate, INSTR(ddate, ',') + 1)) AS order_year
		from
			(
				SELECT
					*
					,TRIM(SUBSTR(ddate, 1, INSTR(ddate, ',') -1)) AS month_day
				from
					(
						SELECT
							*
							,TRIM(SUBSTR(OrderDate, 1, INSTR(OrderDate, ',') - 1)) AS order_day_of_week
							,TRIM(SUBSTR(OrderDate, INSTR(OrderDate, ',') + 1)) AS ddate
						FROM
							(
							SELECT "SalesOrderNumber", "OrderDate", "ProductKey", "ResellerKey", "EmployeeKey", "SalesTerritoryKey", "Quantity", "Unit Price", "Sales", "Cost" FROM "Sales"
							)
					)
			)
	
;

create table adventureworks_2022_denormalized
as 
Select 
	main.*
	,te.Target as target
	,te.TargetMonth as target_date
	,te.day_of_week as target_date_day_of_week
	,te.mmonth as target_date_month
	,te.dday as target_date_day
	,te.yyear as target_date_year
from
	(
		SELECT
			s.SalesOrderNumber as sales_order_number,
			s.OrderDate as sales_order_date,
			s.order_day_of_week as sales_order_date_day_of_week,
			s.order_month as sales_order_date_month,
			s.order_day as sales_order_date_day,
			s.order_year as sales_order_date_year,
			s.Quantity as quantity,
			s."Unit Price" as unit_price,
			s."Sales" as total_sales,
			s.Cost as cost,
			s.ProductKey as product_key,
			p."Product" as product_name,
			s.ResellerKey as reseller_key,
			rs."Reseller" as reseller_name,
			rs."Business Type" as reseller_business_type,
			rs."City" as reseller_city,
			rs."State-Province" as reseller_state,
			rs."Country-Region" as reseller_country,
			s.EmployeeKey as employee_key,
			sp.EmployeeID as employee_id,
			sp."Salesperson" as salesperson_fullname,
			sp."Title" as salesperson_title,
			sp."UPN" as email_address,
			s.SalesTerritoryKey as sales_territory_key,
			spr.salesterritorykeys as assigned_sales_territory,
			rg."Region" as sales_territory_region,
			rg."Country" as sales_territory_country,
			rg."Group" as sales_territory_group
		from
			sales_expanded as s
			left join Product p on s.ProductKey = p.ProductKey
			left join Reseller rs on s.ResellerKey = rs.ResellerKey
			left join Salesperson sp on s.EmployeeKey = sp.EmployeeKey 
			left join Region rg on s.SalesTerritoryKey = rg.SalesTerritoryKey
			left join (
				SELECT
					employeekey,
					GROUP_CONCAT(salesterritorykey) AS salesterritorykeys
				FROM
					SalespersonRegion
				GROUP BY
					employeekey
			) spr on s.EmployeeKey = spr.employeekey
	) main
	left join Targets_expanded te on main.employee_id = te.EmployeeID and main.sales_order_date_month = te.mmonth and main.sales_order_date_year = te.yyear
;