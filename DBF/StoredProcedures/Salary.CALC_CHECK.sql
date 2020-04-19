USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[CALC_CHECK]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		/*
		проверка корректности:
		1. Чтобы у СИ стоял признак Резидента
		2. Чтобы у резидента был заполнен бызовый город
		3. Чтобы у клиента был указан тип
		4. Чтобы у населенного пункта всегда был указан базовый (хотя бы для тех, которые расчитываются по резидентам)
		*/

		SELECT COUR_NAME AS [Значение], 'Не указан тип СИ' AS [Тип проверки]
		FROM dbo.CourierTable
		WHERE COUR_ACTIVE = 1
			AND COUR_ID_TYPE IS NULL
			
		UNION ALL
			
		SELECT COUR_NAME, 'Не указан базовый город'
		FROM dbo.CourierTable
		WHERE COUR_ACTIVE = 1
			AND COUR_ID_TYPE = 2
			AND COUR_ID_CITY IS NULL

		UNION ALL
			
		SELECT CL_PSEDO, 'Не указан тип клиента'
		FROM 
			dbo.ClientTable
			INNER JOIN dbo.TOTable ON TO_ID_CLIENT = CL_ID
			INNER JOIN dbo.CourierTable ON COUR_ID = TO_ID_COUR
		WHERE CL_ID_TYPE IS NULL AND COUR_ID_TYPE = 2

		UNION ALL

		SELECT CT_NAME, 'Не указан базовый населенный пункт для населенного пункта'
		FROM 
			(
				SELECT DISTINCT ST_ID_CITY
				FROM 
					dbo.TOTable
					INNER JOIN dbo.CourierTable ON COUR_ID = TO_ID_COUR
					INNER JOIN dbo.TOAddressTable ON TA_ID_TO = TO_ID
					INNER JOIN dbo.StreetTable ON ST_ID = TA_ID_STREET
				WHERE COUR_ID_TYPE = 2
			) AS o_O
			INNER JOIN dbo.CityTable ON ST_ID_CITY = CT_ID
		WHERE CT_ID_BASE IS NULL
		ORDER BY 2, 1
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
