USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_SEARCH]
	@psedo VARCHAR(100),
	@inn VARCHAR(50),
	@tonum INT,
	@courid INT,
	@disnum INT,
	@sysid INT,
	@conum VARCHAR(100),
	@typeid INT,
	@fam VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@phone VARCHAR(100) = null,
	@adtypeid SMALLINT = null,
	@streetid INT = null,
	@home VARCHAR(50) = null,
	@billnum VARCHAR(50) = NULL,
	@insnum VARCHAR(20) = NULL,
	@paynum VARCHAR(20) = NULL,
	@paydate SMALLDATETIME = NULL,
	@cityid SMALLINT = NULL,
	@fullname VARCHAR(250) = NULL,
	@org SMALLINT = NULL,
	@copay SMALLINT = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @sql NVARCHAR(MAX)
		DECLARE @where NVARCHAR(MAX)

		IF @phone IS NOT NULL
			SET @phone = '%' + @phone

		IF @psedo IS NOT NULL
			SET @psedo = '%' + @psedo

		SET @where = ''
		SET @sql = '

		SELECT CL_ID, CL_PSEDO, CL_FULL_NAME, UNKNOWN_FINANCING, '

		IF DB_ID('DBF_NAH') IS NOT NULL
			SET @sql = @sql + '(SELECT COUNT(*) FROM DBF_NAH.dbo.ClientTable z WHERE z.CL_NUM = a.CL_NUM)'
		ELSE
			SET @sql = @sql + '0'

		SET @sql = @sql + ' AS CL_NAH
		FROM
			dbo.ClientTable a LEFT OUTER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
		WHERE EXISTS
			(
				SELECT *
				FROM
					dbo.ClientTable b '

		IF (@tonum IS NOT NULL) OR (@courid IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOTable c ON c.TO_ID_CLIENT = b.CL_ID '
		END

		IF (@disnum IS NOT NULL) OR (@sysid IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN
					dbo.ClientDistrTable d ON d.CD_ID_CLIENT = b.CL_ID LEFT OUTER JOIN
					dbo.DistrView e WITH(NOEXPAND) ON e.DIS_ID = d.CD_ID_DISTR '
		END

		IF (@conum IS NOT NULL) OR (@typeid IS NOT NULL) OR (@copay IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.ContractTable f ON f.CO_ID_CLIENT = b.CL_ID '
		END

		IF (@fam IS NOT NULL) OR (@name IS NOT NULL) OR (@otch IS NOT NULL) OR (@phone IS NOT NULL)
		BEGIN
			IF (@tonum IS NULL) AND (@courid IS NULL)
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOTable c ON c.TO_ID_CLIENT = b.CL_ID
					 LEFT OUTER JOIN dbo.TOPersonalTable g ON g.TP_ID_TO = c.TO_ID '
			ELSE
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOPersonalTable g ON d.TP_ID_TO = c.TO_ID '
		END

		IF (@adtypeid IS NOT NULL) OR (@streetid IS NOT NULL) OR (@home IS NOT NULL) OR (@cityid IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.ClientAddressTable h ON h.CA_ID_CLIENT = b.CL_ID '

			IF (@tonum IS NULL) AND (@courid IS NULL) AND (@fam IS NULL) AND (@name IS NULL) AND (@otch IS NULL) AND (@phone IS NULL)
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOTable c ON c.TO_ID_CLIENT = b.CL_ID '
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOAddressTable q ON c.TO_ID = q.TA_ID_TO '
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.StreetTable w ON q.TA_ID_STREET = w.ST_ID '
		END

		IF (@cityid IS NOT NULL)
		BEGIN
			IF (@adtypeid IS NOT NULL) OR (@streetid IS NOT NULL) OR (@home IS NOT NULL) OR (@cityid IS NOT NULL)
			BEGIN
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.StreetTable z ON z.ST_ID = h.CA_ID_STREET '
			END
			ELSE
			BEGIN
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.ClientAddressTable h ON h.CA_ID_CLIENT = b.CL_ID '
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.StreetTable z ON z.ST_ID = h.CA_ID_STREET '
			END
		END

		IF (@billnum IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.BillFactMasterTable i ON b.CL_ID = i.CL_ID '
		END

		IF (@insnum IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.InvoiceSaleTable j ON j.INS_ID_CLIENT = b.CL_ID '
		END

		IF (@paynum IS NOT NULL) OR (@paydate IS NOT NULL)
		BEGIN
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.IncomeTable k ON k.IN_ID_CLIENT = b.CL_ID '
		END

		IF @fullname IS NOT NULL
		BEGIN
			IF (@tonum IS NULL) AND (@courid IS NULL) AND (@fam IS NULL) AND (@name IS NULL) AND (@otch IS NULL) AND (@phone IS NULL) AND (@adtypeid IS NULL) AND (@streetid IS NULL) AND (@home IS NULL) AND (@cityid IS NULL)
			BEGIN
				SET @sql = @sql + 'LEFT OUTER JOIN dbo.TOTable c ON c.TO_ID_CLIENT = b.CL_ID '
			END
		END

		IF @psedo IS NOT NULL
		BEGIN
			SET @where = @where + ' AND b.CL_PSEDO LIKE @psedo'
		END

		IF @fullname IS NOT NULL
		BEGIN
			SET @where = @where + ' AND (b.CL_FULL_NAME LIKE @fullname OR TO_NAME LIKE @fullname OR CL_PSEDO LIKE @fullname OR CL_SHORT_NAME LIKE @fullname)'
		END

		IF @inn IS NOT NULL
		BEGIN
			SET @where = @where + ' AND b.CL_INN = @inn'
		END

		IF @tonum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND c.TO_NUM = @tonum'
		END

		IF @courid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND c.TO_ID_COUR = @courid'
		END

		IF @disnum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND e.DIS_NUM = @disnum'
		END

		IF @sysid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND e.SYS_ID = @sysid'
		END

		IF @conum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND f.CO_NUM LIKE @conum'
		END

		IF @typeid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND f.CO_ID_TYPE = @typeid'
		END

		IF @copay IS NOT NULL
		BEGIN
			SET @where = @where + ' AND f.CO_ID_PAY = @copay'
		END

		IF @fam IS NOT NULL
		BEGIN
			SET @where = @where + ' AND g.TP_SURNAME LIKE @fam'
		END

		IF @name IS NOT NULL
		BEGIN
			SET @where = @where + ' AND g.TP_NAME LIKE @name'
		END

		IF @otch IS NOT NULL
		BEGIN
			SET @where = @where + ' AND g.TP_OTCH LIKE @otch'
		END

		IF @phone IS NOT NULL
		BEGIN
			SET @where = @where + ' AND g.TP_PHONE LIKE @phone'
		END

		IF @adtypeid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND h.CA_ID_TYPE = @adtypeid'
		END

		IF @streetid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND (h.CA_ID_STREET = @streetid OR q.TA_ID_STREET = @streetid)'
		END

		IF @home IS NOT NULL
		BEGIN
			SET @where = @where + ' AND (h.CA_HOME LIKE @home OR q.TA_HOME LIKE @home)'
		END

		IF @cityid IS NOT NULL
		BEGIN
			SET @where = @where + ' AND (z.ST_ID_CITY = @cityid OR w.ST_ID_CITY = @cityid)'
		END

		IF @billnum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND i.BFM_NUM LIKE @billnum'
		END

		IF @insnum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND @insnum =
										CASE CHARINDEX(''/'', @insnum)
											WHEN 0 THEN CONVERT(VARCHAR(20), j.INS_NUM)
											ELSE CONVERT(VARCHAR(20), j.INS_NUM) + ''/'' + CONVERT(VARCHAR(20), j.INS_NUM_YEAR)
										END '
		END

		IF @paynum IS NOT NULL
		BEGIN
			SET @where = @where + ' AND k.IN_PAY_NUM = @paynum'
		END

		IF @paydate IS NOT NULL
		BEGIN
			SET @where = @where + ' AND k.IN_DATE = @paydate'
		END

		IF @org IS NOT NULL
		BEGIN
			SET @where = @where + ' AND b.CL_ID_ORG = @org'
		END

		SET @sql = @sql + '
				WHERE a.CL_ID = b.CL_ID ' + @where + '
			)
		ORDER BY CL_PSEDO'

		PRINT @sql

		EXEC sp_executesql @sql,
		N'@psedo VARCHAR(100), @inn VARCHAR(50), @tonum INT, @courid INT, @disnum INT, @sysid INT, @conum VARCHAR(100), @typeid INT, @fam VARCHAR(100), @name VARCHAR(100), @otch VARCHAR(100), @phone VARCHAR(100), @adtypeid SMALLINT, @streetid INT, @home VARCHAR(50), @billnum VARCHAR(50), @insnum VARCHAR(20), @paynum VARCHAR(20), @paydate SMALLDATETIME, @cityid SMALLINT, @fullname VARCHAR(250), @org SMALLINT, @copay SMALLINT',
		@psedo, @inn, @tonum, @courid, @disnum, @sysid, @conum, @typeid, @fam, @name, @otch, @phone, @adtypeid, @streetid, @home, @billnum, @insnum, @paynum, @paydate, @cityid, @fullname, @org, @copay

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO rl_client_fin_r;
GRANT EXECUTE ON [dbo].[CLIENT_SEARCH] TO rl_client_r;
GO