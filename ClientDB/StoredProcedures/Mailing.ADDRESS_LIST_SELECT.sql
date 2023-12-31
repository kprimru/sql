USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Mailing].[ADDRESS_LIST_SELECT]
	@NAME			VARCHAR(250)	= NULL,
	@STATUS			TINYINT			= NULL,
	@DISTR			INT				= NULL,
	@EMAIL			NVARCHAR(250)	= NULL,
	@DATE_BEGIN		DATETIME		= NULL,
	@DATE_END		DATETIME		= NULL,
	@ISNEW			BIT				= 0
AS
BEGIN
	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @NAME = '%' + NullIf(@NAME, '') + '%';
		SET @EMAIL = '%' + NullIf(@EMAIL, '') + '%';

		SELECT	a.ID								,
				d.ClientID							,
				CASE WHEN ClientFullName IS NULL THEN Comment ELSE ClientFullName END AS [Name],
				d.ServiceTypeID						,
				c.DS_INDEX							,
				IsNull(d.ManagerName, c.SubhostName)AS [Manager],
				d.ServiceName						,
				a.Distr								,
				CASE WHEN ((a.Email IS NULL) OR (a.Email='')) THEN a.OriginalEmail ELSE a.Email END	AS [EMail],
				a.UpdateDate						,
				CASE WHEN ((a.Email IS NULL) OR (a.Email='')) THEN 1 ELSE 0 END AS IsNew,
				SendDate,
				Cast(CASE WHEN C.SubhostName != '' THEN 1 ELSE 0 END AS Bit) AS IsSubhost,
				ConfirmDate

		FROM	Mailing.Requests a
				INNER JOIN			Reg.RegNodeSearchView c WITH(NOEXPAND)	ON a.Comp = c.CompNumber AND a.Distr = c.DistrNumber AND a.HostID = c.HostID
				LEFT OUTER JOIN		dbo.ClientDistrView b	WITH(NOEXPAND)	ON a.Comp = b.COMP AND a.Distr = b.DISTR AND a.HostID = b.HostID
				LEFT OUTER JOIN		dbo.ClientView d		WITH(NOEXPAND)	ON b.ID_CLIENT = d.ClientID

		WHERE	(d.ClientFullName LIKE @NAME OR c.Comment LIKE @NAME OR @NAME IS NULL)
			AND (d.ServiceTypeID = @STATUS OR @STATUS IS NULL)
			AND (a.Distr = @DISTR OR @DISTR IS NULL)
			AND (a.OriginalEmail LIKE @EMAIL OR a.Email LIKE @EMAIL OR @EMAIL IS NULL)
			AND (a.UpdateDate > @DATE_BEGIN OR @DATE_BEGIN IS NULL)
			AND (a.UpdateDate < @DATE_END OR @DATE_END IS NULL)
			AND ((C.SubhostName = '' AND (a.Email IS NULL) OR (a.Email='')) OR (a.ConfirmDate IS NULL AND C.SubhostName != '') OR @ISNEW=0)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Mailing].[ADDRESS_LIST_SELECT] TO rl_mailing_req;
GO
