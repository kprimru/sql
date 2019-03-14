USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Изменить данные о технологическом 
               признаке с указанным кодом
*/

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_EDIT] 
	@id SMALLINT,
	@name VARCHAR(20),  
	@reg SMALLINT,  
	@coef DECIMAL(10, 4),
	@calc DECIMAL(4, 2),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.TechnolTypeTable
	SET TT_NAME = @name,   
		TT_REG = @reg,    
		TT_COEF = @coef,
		TT_CALC = @calc,
		TT_ACTIVE = @active
	WHERE TT_ID = @id	

	UPDATE t
	SET TTP_COEF = @coef
	FROM 
		dbo.TechnolTypePeriod t
		INNER JOIN dbo.PeriodTable ON TTP_ID_PERIOD = PR_ID
	WHERE TTP_ID_TECH = @id AND PR_DATE > GETDATE()
	

	SET NOCOUNT OFF
END