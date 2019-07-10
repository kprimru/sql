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

CREATE PROCEDURE [dbo].[BANK_CHECK_NAME] 
	@bankname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT BA_ID 
	FROM dbo.BankTable 
	WHERE BA_NAME = @bankname

	SET NOCOUNT OFF
END