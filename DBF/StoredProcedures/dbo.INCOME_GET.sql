USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������
��������:		
*/

CREATE PROCEDURE [dbo].[INCOME_GET]
	@inid INT

AS
BEGIN
	SET NOCOUNT ON;

	SELECT IN_DATE, IN_SUM, IN_PAY_DATE, IN_PAY_NUM, IN_PRIMARY
	FROM dbo.IncomeTable
	WHERE IN_ID = @inid	
END

