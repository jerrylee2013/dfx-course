import { microblog } from "../../declarations/microblog";
import React, { useState, useEffect, useRef } from 'react';

import {Card} from 'antd';

import BlogTable from "./blogtable";

const TimeLine = (props) => {
    // const actionRef = useRef();

    return (<Card title="查询指定时间内所有所关注的博主文章列表">
        <BlogTable 
            microblogMethod={microblog.timeline}
            showTimeFilter={true}
            showAuthor={true}
        />
    </Card>)
}

export default TimeLine;