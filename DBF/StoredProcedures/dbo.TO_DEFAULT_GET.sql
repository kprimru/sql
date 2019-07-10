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

CREATE PROCEDURE [dbo].[TO_DEFAULT_GET]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 1
		CL_FULL_NAME AS TO_NAME, CL_INN,
		(
			SELECT MAX(TO_NUM) + 1
			FROM dbo.TOTable			
		) AS TO_NUM,
		ST_NAME, ST_ID, CA_INDEX, CA_HOME,
		CASE 
			(
				SELECT COUNT(*)
				FROM dbo.TOTable
				WHERE TO_ID_CLIENT = @clientid
					AND TO_MAIN = 1
			)
			WHEN 0 THEN 1
			ELSE 0
		END AS TO_MAIN
	FROM 
		dbo.ClientTable LEFT OUTER JOIN
		dbo.ClientAddressTable ON CA_ID_CLIENT = CL_ID LEFT OUTER JOIN
		dbo.StreetTable ON ST_ID = CA_ID_STREET
	WHERE CL_ID = @clientid 
	ORDER BY CA_ID_TYPE DESC, ISNULL(ST_ID, 0) DESC

END



