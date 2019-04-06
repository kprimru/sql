USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[COUNTRY_ADD] 
	@countryname VARCHAR(100), 
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.CountryTable(CNT_NAME, CNT_ACTIVE, CNT_OLD_CODE) 
	VALUES (@countryname, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
