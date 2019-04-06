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

CREATE PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_EDIT]
	@cdsid INT,
	@clientid INT,
	@actcontract VARCHAR(100),
	@actpos VARCHAR(200),
	@actposf VARCHAR(200),
	@actname VARCHAR(500),
	@actnamef VARCHAR(500),
	@billrest BIT,
	@inscontract BIT,
	@insname VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientDocumentSettingsTable
	SET	CDS_ID_CLIENT = @clientid, 
		CDS_ACT_CONTRACT = @actcontract, 
		CDS_ACT_POS = @actpos,
		CDS_ACT_POS_F = @actposf, 
		CDS_ACT_NAME = @actname, 
		CDS_ACT_NAME_F = @actnamef, 
		CDS_BILL_REST = @billrest, 
		CDS_INS_CONTRACT = @inscontract, 
		CDS_INS_NAME = @insname		
	WHERE CDS_ID = @cdsid				
END
