USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[BILL_CREATE_DEFAULT_GET]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT SO_ID, SO_NAME
	FROM dbo.SaleObjectTable
	WHERE SO_ID = 1
END

