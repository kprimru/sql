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

CREATE PROCEDURE [dbo].[BANK_DELETE] 
	@bankid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.BankTable WHERE BA_ID = @bankid

	SET NOCOUNT OFF
END