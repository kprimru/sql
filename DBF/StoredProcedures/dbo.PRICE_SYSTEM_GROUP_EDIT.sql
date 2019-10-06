USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/
CREATE PROCEDURE [dbo].[PRICE_SYSTEM_GROUP_EDIT]
	@sysid SMALLINT,
	@pgdid SMALLINT,
	@prid SMALLINT,
	@groupid SMALLINT,
	@pricestr VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @price TABLE
		(
			ID SMALLINT IDENTITY(1, 1),
			PS_VAL MONEY
		)

	SET @pricestr = REPLACE(@pricestr, ',', '.')

	INSERT INTO @price
		SELECT *
		FROM dbo.GET_MONEY_TABLE_FROM_LIST(@pricestr, ';')
		
	DECLARE PT CURSOR LOCAL FOR
		SELECT PT_ID
		FROM dbo.PriceTypeTable
		WHERE PT_ID_GROUP = @groupid
		ORDER BY PT_ID
	
	OPEN PT

	DECLARE @pt SMALLINT

	FETCH NEXT FROM PT INTO @pt

	DECLARE @ps SMALLINT
	
	SET @ps = 1
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @sysid IS NOT NULL
		BEGIN
			IF EXISTS
				(
					SELECT *
					FROM dbo.PriceSystemTable
					WHERE PS_ID_PERIOD = @prid
						AND PS_ID_SYSTEM = @sysid
						AND PS_ID_TYPE = @pt
				)
			BEGIN
-------------------------------------------------------------------
				IF (@sysid BETWEEN 27 AND 35)OR(@sysid=17)
					UPDATE dbo.PriceSystemTable
					SET PS_PRICE = (SELECT PS_VAL FROM @price WHERE ID = @ps)
					WHERE PS_ID_PERIOD = @prid
						AND ((PS_ID_SYSTEM BETWEEN 27 AND 35)OR(PS_ID_SYSTEM=17))
						AND PS_ID_TYPE = @pt
				
				ELSE IF (@sysid BETWEEN 36 AND 44)OR(@sysid BETWEEN 54 AND 61) OR (@sysid=52) OR (@sysid=88)
					UPDATE dbo.PriceSystemTable
					SET PS_PRICE = (SELECT PS_VAL FROM @price WHERE ID = @ps)
					WHERE PS_ID_PERIOD = @prid
						AND ((PS_ID_SYSTEM BETWEEN 36 AND 44)OR(PS_ID_SYSTEM BETWEEN 54 AND 61) OR (PS_ID_SYSTEM=52) OR (PS_ID_SYSTEM=88))
						AND PS_ID_TYPE = @pt
				
				ELSE
----------------------------------------------------------------------
					UPDATE dbo.PriceSystemTable
					SET PS_PRICE = (SELECT PS_VAL FROM @price WHERE ID = @ps)
					WHERE PS_ID_PERIOD = @prid
						AND PS_ID_SYSTEM = @sysid
						AND PS_ID_TYPE = @pt
			END
			ELSE
			BEGIN
				INSERT INTO dbo.PriceSystemTable(PS_ID_SYSTEM, PS_ID_PERIOD, PS_ID_TYPE, PS_PRICE)
					SELECT @sysid, @prid, @pt, (SELECT PS_VAL FROM @price WHERE ID = @ps)
			END
		END
		ELSE
		BEGIN
			IF EXISTS
				(
					SELECT *
					FROM dbo.PriceSystemTable
					WHERE PS_ID_PERIOD = @prid
						AND PS_ID_PGD = @pgdid
						AND PS_ID_TYPE = @pt
				)
			BEGIN
				UPDATE dbo.PriceSystemTable
				SET PS_PRICE = (SELECT PS_VAL FROM @price WHERE ID = @ps)
				WHERE PS_ID_PERIOD = @prid
					AND PS_ID_PGD = @pgdid
					AND PS_ID_TYPE = @pt
			END
			ELSE
			BEGIN			
				INSERT INTO dbo.PriceSystemTable(PS_ID_PGD, PS_ID_PERIOD, PS_ID_TYPE, PS_PRICE)
					SELECT @pgdid, @prid, @pt, (SELECT PS_VAL FROM @price WHERE ID = @ps)
			END
		END

		SET @ps = @ps + 1

		FETCH NEXT FROM PT INTO @pt
	END

	CLOSE PT
	DEALLOCATE PT

	EXEC dbo.PRICE_DEPEND_RECALC @prid, @sysid, @groupid
END