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

CREATE PROCEDURE [dbo].[PLUG_SET_ACT]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ActTable
	SET ACT_ID_INVOICE = 
		(
			SELECT INS_ID 
			FROM dbo.InvoiceSaleTable
			WHERE INS_NUM = '0'
				AND INS_NUM_YEAR = '0'
		)
	WHERE ACT_ID = @actid
END
