USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Din].[SystemType]
(
        [SST_ID]          Int            Identity(1,1)   NOT NULL,
        [SST_NAME]        VarChar(100)                   NOT NULL,
        [SST_SHORT]       VarChar(20)                        NULL,
        [SST_NOTE]        VarChar(100)                   NOT NULL,
        [SST_REG]         VarChar(50)                    NOT NULL,
        [SST_ID_MASTER]   Int                                NULL,
        [SST_WEIGHT]      Bit                                NULL,
        [SST_COMPLECT]    Bit                                NULL,
        [SST_SALARY]      decimal                            NULL,
        CONSTRAINT [PK_Din.SystemType] PRIMARY KEY CLUSTERED ([SST_ID])
);
GO
