USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_NAME_LIST]
	@LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
			REVERSE(STUFF(REVERSE(
				(			
					SELECT a.ClientFullName + ', ' 
					FROM 
						dbo.ClientTable a
						INNER JOIN dbo.TableIDFromXML(@LIST) b ON a.ClientID = b.ID
					ORDER BY a.ClientFullName FOR XML PATH('')
				)
				), 1, 2, '')) AS NAME
END