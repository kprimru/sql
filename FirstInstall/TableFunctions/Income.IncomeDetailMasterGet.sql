USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [Income].[IncomeDetailMasterGet]
(	
	@ID_ID	UNIQUEIDENTIFIER
)
RETURNS 
@TBL TABLE 
(
	ID_ID UNIQUEIDENTIFIER
)
AS
BEGIN
	INSERT INTO @TBL
		SELECT @ID_ID		

		UNION	
		
		SELECT ID_ID_MASTER
		FROM 
			Income.IncomeFullView
		WHERE ID_ID = @ID_ID	
		
	
	RETURN 
END
