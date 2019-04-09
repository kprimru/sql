USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_EMAIL_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT ML
	FROM
		(
			SELECT ClientEMail AS ML
			FROM dbo.ClientTable
			WHERE ClientID = @CLIENT
				AND STATUS = 1
			
			UNION ALL
			
			SELECT DISTINCT CP_EMAIL
			FROM 
				dbo.ClientPersonal
				INNER JOIN dbo.ClientTable ON ClientID = CP_ID_CLIENT
			WHERE CP_ID_CLIENT = @CLIENT
				AND STATUS = 1
			
			UNION ALL
			
			SELECT DISTINCT EMAIL
			FROM dbo.ClientDelivery
			WHERE ID_CLIENT = @CLIENT
				
			UNION ALL
			
			SELECT DISTINCT EMAIL
			FROM dbo.ClientDutyTable
			WHERE ClientID = @CLIENT
				AND STATUS = 1
		) AS o_O
	WHERE ISNULL(ML, '') <> ''
END
