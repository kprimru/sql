USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Сделать копию указанного 
               прейскуранта (тип-период) на 
               указанный тип-период
*/

CREATE PROCEDURE [dbo].[PRICE_GROUP_COPY] 	
	@sourceperiodid SMALLINT,	
	@destperiodid SMALLINT,
	@groupid SMALLINT,
	@coef DECIMAL(8, 4) = 1
AS
BEGIN
	SET NOCOUNT ON
	
	DELETE
	FROM dbo.PriceSystemTable
	WHERE PS_ID IN
		(
			SELECT PS_ID
			FROM 
				dbo.PriceSystemTable INNER JOIN
				dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
			WHERE PS_ID_PERIOD = @destperiodid AND
				PT_ID_GROUP = @groupid    
		)	

	--скопировать данные систем в таблицу
	INSERT INTO dbo.PriceSystemTable (PS_ID_PERIOD, PS_ID_TYPE, PS_ID_SYSTEM, PS_ID_PGD, PS_PRICE)
		SELECT 
			@destperiodid, PS_ID_TYPE, PS_ID_SYSTEM, PS_ID_PGD, 
			CASE PT_ID
				WHEN 16 THEN CAST(ROUND(PS_PRICE * @coef, 0) AS MONEY)
				ELSE CAST(ROUND(PS_PRICE * @coef, 2) AS MONEY)
			END
		FROM 
			dbo.PriceSystemTable INNER JOIN
			dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
		WHERE PS_ID_PERIOD = @sourceperiodid AND
			PT_ID_GROUP = @groupid    

	EXEC dbo.PRICE_DEPEND_RECALC @destperiodid, NULL, @groupid

	SET NOCOUNT OFF
END