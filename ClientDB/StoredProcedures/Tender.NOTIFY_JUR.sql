USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[NOTIFY_JUR]
	@TENDER	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 		
		'������ ����!' + CHAR(10) + CLIENT + ' �������� ' + TENDER_TYPE + ' �� ' + SUBJECT + '.' + CHAR(10) + CHAR(10) + 
		'������ ���������� �� ' + ISNULL(CONVERT(NVARCHAR(32), CLAIM_FINISH, 104) + ' �.', '') 
				AS MAIL_BODY		
	FROM
		(
			SELECT				
				b.CLIENT,
				d.PK_NAME AS [TENDER_TYPE], c.URL,
				c.SUBJECT,					
				CLAIM_FINISH,
				c.DATE
			FROM 
				Tender.Tender b
				INNER JOIN Tender.Placement c ON b.ID = c.ID_TENDER
				INNER JOIN Purchase.PurchaseKind d ON c.ID_TYPE = d.PK_ID
			WHERE b.ID = @TENDER
		) AS o_O	
END
