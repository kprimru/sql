USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Описание:		Выбор всех точек обслуживания указанного клиента
*/

CREATE PROCEDURE [dbo].[TO_SELECT]	
	@clientid INT,
	@distr INT = NULL
WITH EXECUTE AS OWNER  
AS
BEGIN	
	SET NOCOUNT ON;

	IF DB_ID('DBF_NAH') IS NOT NULL
		SELECT 
			TO_REPORT, TO_NUM, TO_NAME, TO_ID, COUR_NAME, TO_MAIN, TO_INN, CL_INN, TO_LAST, (SELECT COUNT(*) FROM DBF_NAH.dbo.TOTable z WHERE z.TO_NUM = a.TO_NUM) AS TO_NAH, TO_PARENT,
			ST_CITY_NAME + ', ' + TA_HOME AS TO_ADDRESS
		FROM 
			dbo.TOView a
			LEFT OUTER JOIN dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
		WHERE TO_ID_CLIENT = @clientid
			AND 
				(
					@distr IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM dbo.TODistrView
							WHERE DIS_NUM = @distr
								AND TD_ID_TO = TO_ID
						)
				)
		ORDER BY TO_NUM
	ELSE
		SELECT 
			TO_REPORT, TO_NUM, TO_NAME, TO_ID, COUR_NAME, TO_MAIN, TO_INN, CL_INN, TO_LAST, 0 AS TO_NAH, TO_PARENT,
			ST_CITY_NAME + ', ' + TA_HOME AS TO_ADDRESS
		FROM 
			dbo.TOView a
			LEFT OUTER JOIN dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
		WHERE TO_ID_CLIENT = @clientid
			AND 
				(
					@distr IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM dbo.TODistrView
							WHERE DIS_NUM = @distr
								AND TD_ID_TO = TO_ID
						)
				)
		ORDER BY TO_NUM

	

	SET NOCOUNT OFF		
END