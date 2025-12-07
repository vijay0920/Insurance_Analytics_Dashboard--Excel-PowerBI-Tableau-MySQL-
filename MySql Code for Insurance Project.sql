# KPI 1 No of Invoice by Accnt Exec
use project_file;
select * from invoice;
select 
    account_executive,
    COUNT(CASE WHEN income_class = 'New' THEN invoice_number END) as new_count,
    COUNT(CASE WHEN income_class = 'Cross Sell' THEN invoice_number END) as cross_sell_count,
    COUNT(CASE WHEN income_class = 'Renewal' THEN invoice_number END) as renewal_count,
    COUNT(invoice_number) as Invoice_count
from invoice
GROUP BY account_executive
ORDER BY invoice_count desc;

# KPI 2 Yearly Meeting Count 
select * from meeting;
select year(meeting_date)as Meeting_Year, count(*)As Meetings_Count 
from meeting
group by 1;

# KPI 3

USE `project_file`;
DROP procedure IF EXISTS `Data_by_IncomeClass`;

USE `project_file`;
DROP procedure IF EXISTS `project_file`.`Data_by_IncomeClass`;
;

DELIMITER $$
USE `project_file`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Data_by_IncomeClass`(  IncomeClass varchar(20))
BEGIN
	declare Total_Target double;
    
# Target, Invoice, Achieved for Cross Sell, New, Renewal
	SET @Cross_Sell_Target = (SELECT SUM(Cross_sell_bugdet) FROM individual_budgets); 
    SET @New_Target = (SELECT SUM(New_Budget) FROM individual_budgets);
	SET @Renewal_Target = (SELECT SUM(Renewal_Budget) FROM individual_budgets);
	SET @Invoice_value = (SELECT SUM(Amount) FROM invoice WHERE income_class = IncomeClass); 
	SET @Achieved_valu = ((SELECT SUM(Amount) FROM brokerage WHERE income_class = IncomeClass) + 
							(SELECT SUM(Amount) FROM fees WHERE income_class = IncomeClass));

 
	IF IncomeClass = "Cross Sell" THEN SET Total_Target = @Cross_Sell_Target;
		ELSEIF IncomeClass = "New" THEN SET Total_Target = @New_Target;
        ELSEIF IncomeClass = "Renewal" THEN SET Total_Target = @Renewal_Target;
        ELSE SET Total_Target = 0;
	END IF;

#Percentage of Placed Achievement for Cross Sell, New, and Renewal
	SET @Placed_achievement= (SELECT CONCAT(FORMAT((@Achieved_valu / Total_Target)*100,2),'%')); 
	
#Percentage of Invoice Achievement for Cross Sell, New, and Renewal
	SET @Invoice_achievement= (SELECT CONCAT(FORMAT((@Invoice_value / Total_Target)*100,2),'%')); 
    
# Showinf all the required values     
SELECT IncomeClass, Format (Total_Target,0) as Target, Format (@Achieved_valu, 2) as Achieved,
Format (@Invoice_value,0) as Invoice, @Placed_achievement as Placed_Achievement_Percentage,
@Invoice_achievement as Invoice_Achievement_Percentage;
        
END$$

DELIMITER ;
;

# Calling the KPI 3 -

 -- Values for Income Class = "New"
call project_file.Data_by_IncomeClass('new');
 -- Values for Income Class = "Cross Sell"
call project_file.Data_by_IncomeClass('Cross Sell');
 -- Values for Income Class = "Renewal"
call project_file.Data_by_IncomeClass('Renewal');


#KPI 4 Stage Funnel by Revenue
select * from opportunity;
select stage , Sum(revenue_amount) as Revenue from opportunity
group by 1
order by 2 desc;

#KPI 5 No of meeting By Account Exe
select Account_executive as Executive_name,count(account_executive)as Meeting_count 
from meeting
group by 1
order by 2 desc;

#KPI 6 Top Open Opportunity

select * from opportunity;
select opportunity_name, sum(revenue_amount) as Revenue_Amount from opportunity
group by 1
order by 2 desc
limit 5;

# Opportunity Product Distribution
use project_file;
select * from opportunity;
select product_group, count(*) as Poduct_Grp_Opportunity from opportunity
group by 1
order by 2 desc;

