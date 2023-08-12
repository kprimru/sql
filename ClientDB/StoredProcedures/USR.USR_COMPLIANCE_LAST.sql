USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_COMPLIANCE_LAST]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_COMPLIANCE_LAST]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[USR_COMPLIANCE_LAST]
	@DATE		SMALLDATETIME,
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
		@Compliance_NOT_EQUAL		TinyInt;

	DECLARE @Clients Table
	(
	    CL_ID               Int NOT NULL PRIMARY KEY CLUSTERED
	);

	DECLARE @Ib Table
	(
		UD_ID		        Int,
		UD_NAME		        VarChar(50),
		CL_ID		        Int,
		UF_ID		        Int,
		UI_ID_BASE	        SmallInt,
		UI_DISTR	        Int,
		UI_COMP		        TinyInt,
		UIU_DATE	        SmallDateTime,
		PREV_UPDATE	        SmallDateTime,
		FIRST_DATE	        SmallDateTime,
        PRIMARY KEY CLUSTERED(UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE)
	);

	DECLARE @Compliance Table
	(
		UF_ID		        Int,
		UI_ID_BASE	        SmallInt,
		UI_DISTR	        Int,
		UI_COMP		        TinyInt,
		UIU_DATE	        SmallDateTime,
		UIU_INDX	        TinyInt,
		COMP		        TinyInt,
        PRIMARY KEY CLUSTERED(UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        IF @DATE IS NULL
            SET @DATE = DateAdd(MONTH, -3, dbo.DateOf(GetDate()));

		SELECT @Compliance_NOT_EQUAL = ComplianceTypeID
		FROM [dbo].[ComplianceTypeTable]
		WHERE ComplianceTypeName = '#HOST'

        INSERT INTO @Clients
        SELECT R.WCL_ID
        FROM [dbo].[ClientList@Get?Read]()  AS R
        INNER JOIN dbo.ClientView           AS C WITH(NOEXPAND) ON R.WCL_ID = C.ClientID
        WHERE (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL);

        INSERT INTO @ib(UD_ID, UD_NAME, CL_ID, UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE)
		SELECT
			UD_ID, dbo.DistrString(S.SystemShortName, UA.UD_DISTR, UA.UD_COMP), UD_ID_CLIENT, UF_ID,
			UI_ID_BASE, UI_DISTR, UI_COMP,
			UI_LAST
		FROM @Clients                   AS C
		INNER JOIN USR.USRActiveView    AS UA ON UA.UD_ID_CLIENT = C.CL_ID
        INNER JOIN dbo.SystemTable      AS S ON UA.UF_ID_SYSTEM = S.SystemID
		INNER JOIN USR.USRIB            AS UI ON UA.UF_ID = UI.UI_ID_USR
		INNER JOIN dbo.ClientDistrView  AS CD WITH(NOEXPAND) ON UI.UI_DISTR = CD.DISTR
													        AND UI.UI_COMP = CD.COMP
													        AND CD.ID_CLIENT = C.CL_ID
		CROSS APPLY dbo.SystemBankGet(CD.SystemId, CD.DistrTypeId) AS SB
		WHERE UI.UI_ID_COMP = @Compliance_NOT_EQUAL
			AND SB.InfoBankID = UI.UI_ID_BASE
			AND CD.DS_REG = 0
			AND UI.UI_LAST >= @DATE


		UNION

		SELECT
			UD_ID, dbo.DistrString(S.SystemShortName, UA.UD_DISTR, UA.UD_COMP), UD_ID_CLIENT, UF_ID,
			UI_ID_BASE, UI_DISTR, UI_COMP,
			UI_LAST
		FROM @Clients                       AS C
		INNER JOIN USR.USRActiveView        AS UA ON UA.UD_ID_CLIENT = C.CL_ID
        INNER JOIN dbo.SystemTable          AS S ON UA.UF_ID_SYSTEM = S.SystemID
		INNER JOIN USR.USRIB                AS UI ON UA.UF_ID = UI.UI_ID_USR
		INNER JOIN dbo.DistrConditionView   AS DC ON DC.InfoBankID = UI.UI_ID_BASE
												AND UI.UI_DISTR = DC.DistrNumber
												AND UI.UI_COMP = DC.CompNumber
		INNER JOIN dbo.ClientDistrView      AS CD WITH(NOEXPAND) ON DC.SystemID = CD.SystemID
															AND UI.UI_DISTR = DC.DistrNumber
															AND UI.UI_COMP = DC.CompNumber
															AND CD.ID_CLIENT = C.CL_ID
		WHERE UI.UI_ID_COMP = @Compliance_NOT_EQUAL
			AND CD.DS_REG = 0
			AND UI.UI_LAST >= @DATE
        OPTION(RECOMPILE);

		INSERT INTO @Compliance(UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE, UIU_INDX, COMP)
		SELECT
			UF_ID, IB.UI_ID_BASE, IB.UI_DISTR, IB.UI_COMP, UU.UIU_DATE, UIU_INDX,
			ISNULL(CUI.[UI_ID_COMP], @Compliance_NOT_EQUAL)
		FROM @Ib                    AS IB
		INNER JOIN USR.USRIB        AS UI ON UI.UI_ID_BASE = IB.UI_ID_BASE
								        AND UI.UI_DISTR = IB.UI_DISTR
								        AND UI.UI_COMP = IB.UI_COMP
								        AND UI.UI_ID_USR = IB.UF_ID
		INNER JOIN USR.USRUpdates   AS UU ON UU.UIU_ID_IB = UI.UI_ID
        OUTER APPLY
        (
            SELECT TOP (1) CUI.UI_ID_COMP
            FROM USR.USRFile        AS UF
            INNER JOIN USR.USRIB    AS CUI ON UF.UF_ID = UI_ID_USR
            WHERE UF.UF_ID_COMPLECT = IB.UD_ID
				AND UU.UIU_DATE = CUI.UI_LAST
				AND UI.UI_ID_BASE = CUI.UI_ID_BASE
				AND	UI.UI_DISTR = CUI.UI_DISTR
				AND UI.UI_COMP = CUI.UI_COMP
            -- ToDo - тут завязаны на ID
			ORDER BY UI_ID_COMP DESC
        ) AS CUI
        OPTION(RECOMPILE);

		UPDATE IB
		SET PREV_UPDATE = CMP.UIU_DATE
		FROM @Ib AS IB
        OUTER APPLY
        (
            SELECT TOP (1) UIU_DATE
			FROM @Compliance AS CMP
			WHERE IB.UI_ID_BASE = CMP.UI_ID_BASE
				AND IB.UI_DISTR = CMP.UI_DISTR
				AND IB.UI_COMP = CMP.UI_COMP
				AND IB.UF_ID = CMP.UF_ID
                AND CMP.UIU_INDX <> 1
            ORDER BY UIU_INDX
        ) AS CMP
        OPTION(RECOMPILE);

        UPDATE IB
		SET FIRST_DATE = CMP2.FIRST_DATE
		FROM @Ib AS IB
        OUTER APPLY
        (
			SELECT TOP (1) FIRST_DATE = UIU_DATE
			FROM @Compliance CMP
			WHERE IB.UF_ID = CMP.UF_ID
				AND CMP.UI_ID_BASE = IB.UI_ID_BASE
				AND CMP.UI_DISTR = IB.UI_DISTR
				AND CMP.UI_COMP = IB.UI_COMP
                AND CMP.COMP != @Compliance_NOT_EQUAL
            ORDER BY CMP.UIU_INDX
        ) AS CMP
        OUTER APPLY
        (
			SELECT TOP (1) FIRST_DATE = UIU_DATE
			FROM @Compliance CMP2
			WHERE IB.UF_ID = CMP2.UF_ID
				AND CMP2.UI_ID_BASE = IB.UI_ID_BASE
				AND CMP2.UI_DISTR = IB.UI_DISTR
				AND CMP2.UI_COMP = IB.UI_COMP
                AND CMP2.COMP = @Compliance_NOT_EQUAL
                AND CMP2.UIU_DATE > CMP.FIRST_DATE
            ORDER BY CMP2.UIU_DATE
        ) AS CMP2
        OPTION(RECOMPILE);

        SELECT
			ClientID, ClientFullName, ManagerName, ServiceName, UD_NAME, InfoBankShortName,
			rnsw.Complect,
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), FIRST_DATE, 112), 112) AS FIRST_DATE,
			CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), UIU_DATE, 112), 112) AS UIU_DATE
		FROM
		(
			SELECT DISTINCT UD_NAME, CL_ID, UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, FIRST_DATE, UIU_DATE
			FROM @Ib a
			WHERE EXISTS
				(
					SELECT *
					FROM USR.USRFile b
					INNER JOIN USR.USRIB c ON c.UI_ID_USR = b.UF_ID
					WHERE b.UF_ID_COMPLECT = a.UD_ID
						AND c.UI_ID_BASE = a.UI_ID_BASE
						AND c.UI_DISTR = a.UI_DISTR
						AND c.UI_COMP = a.UI_COMP
						AND c.UI_ID_COMP = @Compliance_NOT_EQUAL
						AND PREV_UPDATE = c.UI_LAST
						AND a.UF_ID <> b.UF_ID
				)

			UNION ALL

			SELECT DISTINCT UD_NAME, CL_ID, UF_ID, UI_ID_BASE, UI_DISTR, UI_COMP, FIRST_DATE, UIU_DATE
			FROM @Ib a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM USR.USRFile b
					INNER JOIN USR.USRIB c ON c.UI_ID_USR = b.UF_ID
					INNER JOIN dbo.ComplianceTypeTable d ON d.ComplianceTypeID = c.UI_ID_COMP
					WHERE b.UF_ID_COMPLECT = a.UD_ID
						AND c.UI_ID_BASE = a.UI_ID_BASE
						AND c.UI_DISTR = a.UI_DISTR
						AND c.UI_COMP = a.UI_COMP
						AND PREV_UPDATE = c.UI_LAST
						AND a.UF_ID <> b.UF_ID
				)
		) AS o_O
		INNER JOIN dbo.InfoBankTable ON InfoBankID = UI_ID_BASE
		INNER JOIN dbo.ClientTable ON ClientID = CL_ID
		INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
		INNER JOIN dbo.ManagerTable ON ManagerTable.ManagerID = ServiceTable.ManagerID
		INNER JOIN Reg.RegNodeSearchView rnsw WITH(NOEXPAND) ON rnsw.DistrNumber = UI_DISTR AND rnsw.CompNumber = UI_COMP AND rnsw.DS_REG = 0
		WHERE InfoBankActive = 1
		ORDER BY ManagerName, ServiceName, ClientFullName, UI_DISTR, UI_COMP, InfoBankOrder
        OPTION(RECOMPILE);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_COMPLIANCE_LAST] TO rl_usr_compliance;
GO
