USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[REG_NODE_SEARCH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[REG_NODE_SEARCH]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[REG_NODE_SEARCH]
    @SYS        NVarChar(MAX)   =    NULL,
    @DISTR      Int             =    NULL,
    @TYPE       NVarChar(MAX)   =    NULL,
    @NET        NVarChar(MAX)   =    NULL,
    @SH         NVarChar(MAX)   =    NULL,
    @COMMENT    NVarChar(150)   =    NULL,
    @STATUS     NVarChar(MAX)   =    NULL,
    @BEGIN      SmallDateTime   =    NULL,
    @END        SmallDateTime   =    NULL,
    @COMPLECT   NVarChar(150)   =    NULL,
    @CNT        Bit             =    NULL,
    @RC         Int             =    NULL   OUTPUT
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        IF OBJECT_ID('tempdb..#temp') IS NOT NULL
        	DROP TABLE #temp
        
        CREATE TABLE #temp
        (
            HST     SmallInt,
            DISTR   Int,
            COMP    TinyInt,
            Primary Key Clustered(Distr, Hst, Comp)
        );

        IF @DISTR IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            WHERE DistrNumber = @DISTR
        ELSE IF @COMMENT IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            WHERE Comment LIKE @COMMENT
        ELSE IF @BEGIN IS NOT NULL OR @END IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            WHERE (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
                AND (RegisterDate <= @END OR @END IS NULL)
        ELSE IF @SYS IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            INNER JOIN dbo.TableIDFromXML(@SYS) b ON a.SystemID = b.ID
        ELSE IF @TYPE IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            INNER JOIN dbo.TableIDFromXML(@TYPE) d ON a.SST_ID = d.ID
        ELSE IF @NET IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            INNER JOIN dbo.TableIDFromXML(@NET) c ON a.NT_ID = c.ID
        ELSE IF @SH IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            INNER JOIN dbo.TableStringFromXML(@SH) e ON a.SubhostName = e.ID

            UNION

            SELECT SC.SC_ID_HOST, SC.SC_DISTR, SC.SC_COMP
            FROM dbo.SubhostComplect AS SC
            INNER JOIN dbo.Subhost AS S ON S.SH_ID = SC.SC_ID_SUBHOST
            INNER JOIN dbo.TableStringFromXML(@SH) e ON S.SH_REG= e.ID
            WHERE SC_COMPLECT IS NULL
        ELSE IF @STATUS IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            INNER JOIN dbo.TableGUIDFromXML(@STATUS) f ON a.DS_ID = f.ID
        ELSE IF @COMPLECT IS NOT NULL
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            WHERE Complect LIKE @COMPLECT
        ELSE IF @CNT = 1
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
            WHERE TransferLeft = 0
        ELSE
            INSERT INTO #temp(HST, DISTR, COMP)
            SELECT HostID, DistrNumber, CompNumber
            FROM Reg.RegNodeSearchView a WITH(NOEXPAND)

        IF @DISTR IS NOT NULL
            DELETE
            FROM #temp
            WHERE DISTR <> @DISTR

        IF @COMMENT IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                        AND Comment LIKE @COMMENT
                )

        IF @BEGIN IS NOT NULL OR @END IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                        AND (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
                        AND (RegisterDate <= @END OR @END IS NULL)
                )

        IF @SYS IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    INNER JOIN dbo.TableIDFromXML(@SYS) b ON a.SystemID = b.ID
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                )

        IF @TYPE IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    INNER JOIN dbo.TableIDFromXML(@TYPE) d ON a.SST_ID = d.ID
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                )

        IF @NET IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    INNER JOIN dbo.TableIDFromXML(@NET) d ON a.NT_ID = d.ID
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                )

        IF @SH IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    INNER JOIN dbo.TableStringFromXML(@SH) e ON a.SubhostName = e.ID
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                ) AND NOT EXISTS
                (
                    SELECT *
                    FROM dbo.SubhostComplect AS SC
                    INNER JOIN dbo.Subhost AS S ON S.SH_ID = SC.SC_ID_SUBHOST
                    INNER JOIN dbo.TableStringFromXML(@SH) e ON S.SH_REG= e.ID
                    WHERE SC.SC_ID_HOST = HST
                        AND SC.SC_DISTR = DISTR
                        AND SC.SC_COMP = COMP
                )

        IF @STATUS IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    INNER JOIN dbo.TableGUIDFromXML(@STATUS) f ON a.DS_ID = f.ID
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                )

        IF @COMPLECT IS NOT NULL
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                        AND Complect LIKE @COMPLECT
                )

        IF @CNT = 1
            DELETE
            FROM #temp
            WHERE NOT EXISTS
                (
                    SELECT *
                    FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
                    WHERE HST = HostID
                        AND DISTR = DistrNumber
                        AND COMP = CompNumber
                        AND TransferLeft = 0
                )

        SELECT
            a.DistrStr, a.SST_SHORT, a.NT_SHORT, TransferCount, TransferLeft,
            a.Comment, Complect, RegisterDate, a.DS_INDEX, SubhostName,
            a.HostID, a.SystemID, DistrNumber, CompNumber,
            SH_ID, SH_NAME, ISNULL(SC_REG, 0) AS SC_REG, ISNULL(SC_USR, 0) AS SC_USR,
            CONVERT(BIT, CASE WHEN a.DS_REG = 0 AND t.ID IS NOT NULL THEN 1 ELSE 0 END) AS BLACK,
            NULL AS BLACK_DATE, NULL AS BLACK_USER, NULL AS BLACK_REASON,
            NULL AS WHITE_DATE, NULL AS WHITE_USER, NULL AS WHITE_REASON,
            ServiceName, ManagerName,
            Weight = W.WEIGHT,
            D.[DisconnectDate],
            C.[ComplectDate]

        FROM #temp z
        INNER JOIN Reg.RegNodeSearchView a WITH(NOEXPAND) ON z.HST = a.HostID AND z.DISTR = a.DistrNumber AND z.COMP = a.CompNumber
        LEFT JOIN dbo.SubhostComplect ON SC_ID_HOST = HostID AND SC_DISTR = DistrNumber AND SC_COMP = CompNumber
        LEFT JOIN dbo.Subhost ON SH_ID = SC_ID_SUBHOST
        LEFT JOIN dbo.BLACK_LIST_REG t ON t.DISTR = z.DISTR AND z.COMP = t.COMP AND t.ID_SYS = a.SystemID AND P_DELETE = 0
        LEFT JOIN dbo.ClientDistrView m WITH(NOEXPAND) ON m.HostID = a.HostID AND m.DISTR = a.DistrNumber AND m.COMP = a.CompNumber
        LEFT JOIN dbo.ClientView n WITH(NOEXPAND) ON n.ClientID = m.ID_CLIENT
        OUTER APPLY
        (
            SELECT TOP (1) WEIGHT
            FROM dbo.WeightView W WITH(NOEXPAND)
            WHERE W.SystemID = a.SystemID
                AND W.SST_ID = a.SST_ID
                AND W.NT_ID = a.NT_ID
            ORDER BY W.Date DESC
        ) AS W
        OUTER APPLY
        (
            SELECT TOP (1) [DisconnectDate] = D.[Date]
            FROM Reg.RegProtocolDisconnectView AS D WITH(NOEXPAND)
            WHERE D.RPR_ID_HOST = z.HST
                AND D.RPR_DISTR = z.DISTR
                AND D.RPR_COMP = z.COMP
            ORDER BY
                D.DATE DESC
        ) AS D
        OUTER APPLY
        (
            SELECT TOP (1) [ComplectDate] = C.[RegisterDate]
            FROM Reg.RegNodeSearchView AS C WITH(NOEXPAND)
            WHERE C.Complect = A.Complect
            ORDER BY Convert(SmallDateTime, C.[RegisterDate], 104) DESC
        ) AS C
        /*
        WHERE (DistrNumber = @DISTR OR @DISTR IS NULL)
        	AND (a.Comment LIKE @COMMENT OR @COMMENT IS NULL)
        	AND (RegisterDate >= @BEGIN OR @BEGIN IS NULL)
        	AND (RegisterDate <= @END OR @END IS NULL)
        */
        ORDER BY a.SystemOrder, DistrNumber, CompNumber

        SELECT @RC = @@ROWCOUNT

        IF OBJECT_ID('tempdb..#temp') IS NOT NULL
            DROP TABLE #temp

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Reg].[REG_NODE_SEARCH] TO rl_reg_node_search;
GO
